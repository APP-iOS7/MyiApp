"""Cloud Functions for the MyI baby-care app.

Phase 2 — 다중 양육자 알림 (Notification-Decisions.md 참고).

- onCreate / onDelete (kind == schedule 만) 시 발신자를 제외한 caregivers 에게 banner push.
- 발신자 식별: Note.creatorID.
- payload 의 noteID 로 클라가 cancel / re-schedule.
- onUpdate 는 lastEditorID 도입 후 별도 처리.
"""

from firebase_functions import firestore_fn
from firebase_functions.options import set_global_options
from firebase_admin import initialize_app, firestore, messaging

initialize_app()

set_global_options(max_instances=10, region="asia-northeast3")


def _baby_caregivers(baby_id: str, exclude_uid: str) -> list[str]:
    db = firestore.client()
    doc = db.collection("babies").document(baby_id).get()
    if not doc.exists:
        return []
    data = doc.to_dict() or {}
    caregivers = data.get("caregiverIDs", []) or []
    return [uid for uid in caregivers if uid != exclude_uid]


def _user_fcm_tokens(uids: list[str]) -> list[str]:
    db = firestore.client()
    tokens: list[str] = []
    for uid in uids:
        doc = db.collection("users").document(uid).get()
        if not doc.exists:
            continue
        data = doc.to_dict() or {}
        token = data.get("fcmToken")
        if token:
            tokens.append(token)
    return tokens


def _creator_name(creator_uid: str) -> str:
    db = firestore.client()
    doc = db.collection("users").document(creator_uid).get()
    if not doc.exists:
        return "양육자"
    data = doc.to_dict() or {}
    return data.get("displayName") or "양육자"


def _send_multicast(tokens: list[str], title: str, body: str, data: dict[str, str]) -> None:
    if not tokens:
        print("no tokens to send")
        return
    message = messaging.MulticastMessage(
        tokens=tokens,
        notification=messaging.Notification(title=title, body=body),
        data=data,
    )
    response = messaging.send_each_for_multicast(message)
    print(f"sent={response.success_count} failed={response.failure_count}")


@firestore_fn.on_document_created(document="babies/{babyId}/notes/{noteId}")
def on_note_created(event: firestore_fn.Event[firestore_fn.DocumentSnapshot | None]) -> None:
    if event.data is None:
        return
    note = event.data.to_dict() or {}
    if note.get("kind") != "schedule":
        return

    baby_id = event.params["babyId"]
    note_id = event.params["noteId"]
    creator = note.get("creatorID", "")
    title_text = note.get("title", "일정")

    receivers = _baby_caregivers(baby_id, exclude_uid=creator)
    tokens = _user_fcm_tokens(receivers)
    creator_name = _creator_name(creator)

    _send_multicast(
        tokens=tokens,
        title="새 일정",
        body=f"{creator_name}님이 '{title_text}'을(를) 추가했어요",
        data={
            "type": "note_created",
            "noteID": note_id,
            "babyID": baby_id,
        },
    )


@firestore_fn.on_document_deleted(document="babies/{babyId}/notes/{noteId}")
def on_note_deleted(event: firestore_fn.Event[firestore_fn.DocumentSnapshot | None]) -> None:
    if event.data is None:
        return
    note = event.data.to_dict() or {}
    if note.get("kind") != "schedule":
        return

    baby_id = event.params["babyId"]
    note_id = event.params["noteId"]
    creator = note.get("creatorID", "")
    title_text = note.get("title", "일정")

    receivers = _baby_caregivers(baby_id, exclude_uid=creator)
    tokens = _user_fcm_tokens(receivers)
    creator_name = _creator_name(creator)

    _send_multicast(
        tokens=tokens,
        title="일정 삭제",
        body=f"{creator_name}님이 '{title_text}'을(를) 삭제했어요",
        data={
            "type": "note_deleted",
            "noteID": note_id,
            "babyID": baby_id,
        },
    )
