from typing import List, Optional, Dict, Any, Tuple
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime
from app.models.diary import DiaryEntry, EmotionalState
from app.schemas.diary import DiaryEntryCreate, DiaryEntryUpdate


class DiaryService:

    @staticmethod
    def get_entry(db: Session, entry_id: int, user_id: int) -> DiaryEntry:
        entry = db.query(DiaryEntry).filter(
            DiaryEntry.id == entry_id,
            DiaryEntry.user_id == user_id
        ).first()
        if not entry:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Запись не найдена"
            )
        return entry

    @staticmethod
    def get_entries(
        db: Session,
        user_id: int,
        skip: int = 0,
        limit: int = 10,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        emotional_state: Optional[EmotionalState] = None
    ) -> Tuple[List[DiaryEntry], int]:
        query = db.query(DiaryEntry).filter(DiaryEntry.user_id == user_id)

        if start_date:
            query = query.filter(DiaryEntry.event_datetime >= start_date)
        if end_date:
            query = query.filter(DiaryEntry.event_datetime <= end_date)
        if emotional_state:
            query = query.filter(DiaryEntry.emotional_state == emotional_state)

        query = query.order_by(DiaryEntry.event_datetime.desc())
        total = query.count()
        entries = query.offset(skip).limit(limit).all()

        return entries, total

    @staticmethod
    def create_entry(db: Session, entry: DiaryEntryCreate, user_id: int) -> DiaryEntry:
        db_entry = DiaryEntry(
            user_id=user_id,
            **entry.model_dump()
        )
        db.add(db_entry)
        db.commit()
        db.refresh(db_entry)
        return db_entry

    @staticmethod
    def update_entry(
        db: Session,
        entry_id: int,
        entry_update: DiaryEntryUpdate,
        user_id: int
    ) -> DiaryEntry:
        db_entry = DiaryService.get_entry(db, entry_id, user_id)
        update_data = entry_update.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_entry, field, value)

        db.commit()
        db.refresh(db_entry)
        return db_entry

    @staticmethod
    def delete_entry(db: Session, entry_id: int, user_id: int) -> bool:
        db_entry = DiaryService.get_entry(db, entry_id, user_id)
        db.delete(db_entry)
        db.commit()
        return True
