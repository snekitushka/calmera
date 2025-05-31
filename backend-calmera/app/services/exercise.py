from typing import List, Optional, Tuple
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import or_

from app.models.exercise import Exercise
from app.schemas.exercise import ExerciseCreate, ExerciseUpdate


class ExerciseService:
    @staticmethod
    def get_exercise(db: Session, exercise_id: int) -> Exercise:
        exercise = db.query(Exercise).filter(Exercise.id == exercise_id).first()
        if not exercise:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Упражнение не найдено"
            )
        return exercise

    @staticmethod
    def get_exercises(
        db: Session,
        skip: int = 0,
        limit: int = 100,
        type: Optional[str] = None,
        search: Optional[str] = None
    ) -> Tuple[List[Exercise], int]:
        query = db.query(Exercise)

        if type:
            query = query.filter(Exercise.type == type)

        if search:
            search_term = f"%{search}%"
            query = query.filter(
                or_(
                    Exercise.title.ilike(search_term),
                    Exercise.description.ilike(search_term),
                    Exercise.instructions.ilike(search_term)
                )
            )

        total = query.count()
        exercises = query.offset(skip).limit(limit).all()
        return exercises, total

    @staticmethod
    def create_exercise(db: Session, exercise: ExerciseCreate) -> Exercise:
        db_exercise = Exercise(**exercise.model_dump())
        db.add(db_exercise)
        db.commit()
        db.refresh(db_exercise)
        return db_exercise

    @staticmethod
    def update_exercise(db: Session, exercise_id: int, exercise_update: ExerciseUpdate) -> Exercise:
        db_exercise = ExerciseService.get_exercise(db, exercise_id)
        update_data = exercise_update.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_exercise, field, value)
        db.commit()
        db.refresh(db_exercise)
        return db_exercise

    @staticmethod
    def delete_exercise(db: Session, exercise_id: int) -> bool:
        db_exercise = ExerciseService.get_exercise(db, exercise_id)
        db.delete(db_exercise)
        db.commit()
        return True
