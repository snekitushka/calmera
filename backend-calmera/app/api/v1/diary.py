from typing import Optional
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session
import math
from datetime import datetime, date

from app.db.session import get_db
from app.dependencies.auth import get_current_user
from app.models.user import User
from app.services.diary import DiaryService
from app.schemas.diary import (
    DiaryEntry,
    DiaryEntryCreate,
    DiaryEntryUpdate,
    DiaryEntryResponse,
    DiaryEntryListResponse,
)

router = APIRouter()

@router.post("", response_model=DiaryEntryResponse, status_code=status.HTTP_201_CREATED)
def create_entry(
    entry: DiaryEntryCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_entry = DiaryService.create_entry(db=db, entry=entry, user_id=current_user.id)
    return DiaryEntryResponse(entry=db_entry)

@router.get("", response_model=DiaryEntryListResponse)
def get_entries(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    skip: int = Query(0, ge=0, description="Skip N items"),
    limit: int = Query(10, ge=1, le=100, description="Limit to N items"),
    start_date: Optional[date] = Query(None, description="Start date (YYYY-MM-DD)"),
    end_date: Optional[date] = Query(None, description="End date (YYYY-MM-DD)"),
):

    start_datetime = datetime.combine(start_date, datetime.min.time()) if start_date else None
    end_datetime = datetime.combine(end_date, datetime.max.time()) if end_date else None
    
    entries, total = DiaryService.get_entries(
        db=db,
        user_id=current_user.id,
        skip=skip,
        limit=limit,
        start_date=start_datetime,
        end_date=end_datetime,
    )
    
    total_pages = math.ceil(total / limit) if total > 0 else 0
    page = skip // limit + 1 if skip % limit == 0 else skip // limit + 1
    
    return DiaryEntryListResponse(
        entries=entries,
        total=total,
        page=page,
        page_size=limit,
        total_pages=total_pages
    )

@router.get("/{entry_id}", response_model=DiaryEntryResponse)
def get_entry(
    entry_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    
    entry = DiaryService.get_entry(db=db, entry_id=entry_id, user_id=current_user.id)
    return DiaryEntryResponse(entry=entry)

@router.put("/{entry_id}", response_model=DiaryEntryResponse)
def update_entry(
    entry_id: int,
    entry_update: DiaryEntryUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    updated_entry = DiaryService.update_entry(
        db=db,
        entry_id=entry_id,
        entry_update=entry_update,
        user_id=current_user.id
    )
    return DiaryEntryResponse(entry=updated_entry)

@router.delete("/{entry_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_entry(
    entry_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):

    DiaryService.delete_entry(db=db, entry_id=entry_id, user_id=current_user.id)
    return None 




