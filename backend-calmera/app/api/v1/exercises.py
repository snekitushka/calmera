from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
import math

from app.db.session import get_db
from app.models.exercise import ExerciseType
from app.schemas.exercise import (
    Exercise, 
    ExerciseCreate, 
    ExerciseUpdate, 
    ExerciseResponse, 
    ExerciseListResponse,
)
from app.services.exercise import ExerciseService

router = APIRouter()

@router.get("/", response_model=ExerciseListResponse)
def get_exercises(
    db: Session = Depends(get_db),
    skip: int = Query(0, ge=0, description="Skip N items"),
    limit: int = Query(10, ge=1, le=100, description="Limit to N items"),
    type: Optional[ExerciseType] = Query(None, description="Filter by exercise type"),
    search: Optional[str] = Query(None, description="Search in title and description")
):
    """
    Получить список упражнений с возможностью фильтрации и поиска
    """
    exercises, total = ExerciseService.get_exercises(
        db=db, 
        skip=skip, 
        limit=limit,
        type=type.value if type else None,
        search=search
    )
    
    total_pages = math.ceil(total / limit) if total > 0 else 0
    page = skip // limit + 1 if skip % limit == 0 else skip // limit + 1
    
    return ExerciseListResponse(
        exercises=exercises,
        total=total,
        page=page,
        page_size=limit,
        total_pages=total_pages
    )

@router.get("/types", response_model=List[str])
def get_exercise_types():
    """
    Получить список всех типов упражнений
    """
    return [t.value for t in ExerciseType]


@router.get("/{exercise_id}", response_model=ExerciseResponse)
def get_exercise(exercise_id: int, db: Session = Depends(get_db)):

    exercise = ExerciseService.get_exercise(db=db, exercise_id=exercise_id)
    return ExerciseResponse(exercise=exercise)

@router.post("/", response_model=ExerciseResponse, status_code=status.HTTP_201_CREATED)
def create_exercise(exercise: ExerciseCreate, db: Session = Depends(get_db)):
    """
    Создать новое упражнение
    """
    db_exercise = ExerciseService.create_exercise(db=db, exercise=exercise)
    return ExerciseResponse(exercise=db_exercise)

@router.put("/{exercise_id}", response_model=ExerciseResponse)
def update_exercise(exercise_id: int, exercise: ExerciseUpdate, db: Session = Depends(get_db)):
    """
    Обновить существующее упражнение
    """
    db_exercise = ExerciseService.update_exercise(
        db=db, 
        exercise_id=exercise_id, 
        exercise_update=exercise
    )
    return ExerciseResponse(exercise=db_exercise)

@router.delete("/{exercise_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_exercise(exercise_id: int, db: Session = Depends(get_db)):
    """
    Удалить упражнение
    """
    ExerciseService.delete_exercise(db=db, exercise_id=exercise_id)
    return None 