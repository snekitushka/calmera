from requests_toolbelt.multipart import decoder
from typing import List, Dict, Any, Tuple
import httpx
import multipart
from sqlalchemy.orm import Session
from openai import OpenAI

from app.core.config import get_settings
from app.models.chat import ChatMessage, MessageType
from app.schemas.chatbot import MessageCreate

settings = get_settings()

class ChatbotService:
    def __init__(self):
        self.client = OpenAI(api_key=settings.OPENAI_API_KEY)
        self.model = settings.OPENAI_MODEL
    
    def get_conversation_history(
        self, db: Session, user_id: int, skip: int = 0,
    ) -> Tuple[List[ChatMessage], int]:
        
        query = db.query(ChatMessage).filter(
            ChatMessage.user_id == user_id
        ).order_by(ChatMessage.created_at.desc())
        
        total = query.count()
        messages = query.offset(skip).all()
        
        return messages, total
    
    
    def process_user_message(self, db: Session, user_id: int, message_data: MessageCreate) -> Dict[str, Any]:
        user_message = ChatMessage(
            user_id=user_id,
            message_type=MessageType.USER,
            content=message_data.content,
        )
        db.add(user_message)
        db.commit()
        db.refresh(user_message)
        
       
        previous_messages, _ = self.get_conversation_history(db, user_id, 0)
        previous_messages.reverse()  

        conversation_context = []
        
        for msg in previous_messages:
            if msg.id != user_message.id: 
                role = "user" if msg.message_type == MessageType.USER else "assistant"
                conversation_context.append({
                    "role": role,
                    "content": msg.content
                })
        
        
        try:
            # Генерирация ответа от бота через OpenAI API
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": self._get_system_message()},
                    *conversation_context,
                    {"role": "user", "content": user_message.content}
                ]
            )
            
            bot_response = response.choices[0].message.content
            
            bot_message = ChatMessage(
                user_id=user_id,
                message_type=MessageType.BOT,
                content=bot_response,
            )
            db.add(bot_message)
            db.commit()
            db.refresh(bot_message)

            return {"message": bot_response}
            
            
        except Exception as e:
            error_message = f"Техническая ошибка: {str(e)}"
            print(f"ERROR in process_user_message: {error_message}")
            
            bot_message = ChatMessage(
                user_id=user_id,
                message_type=MessageType.BOT,
                content=f"Извините, у меня возникли технические трудности: {str(e)}. Пожалуйста, повторите ваше сообщение позже.",
            )
            db.add(bot_message)
            db.commit()
            db.refresh(bot_message)

            return {"message": bot_message.content}

    def _get_system_message(self) -> str:
        return ("""
        Тебя зовут Татьяна. Ты профессиональный психолог, специализирующийся на когнитивно-поведенческой терапии. У тебя есть лицензия психотерапевта. Задавай по одному вопросу за раз и дай мне полностью ответить, прежде чем переходить к другому. Твоя цель как лучшего психолога — помочь мне преодолеть проблемы и травмы. Уважай мои личные границы. Если я не понимаю, что меня беспокоит, ты можешь задавать открытые вопросы. Начни наш первый сеанс так: «Я Татьяна, я твой психолог и буду помогать тебе. Как мне к тебе обращаться?». Для того чтобы наша беседа была приятной и поддерживающей: Татьяна будет проявлять теплоту и сочувствие. Татьяна будет использовать мое имя в течение всего нашего разговора. Татьяна стремится создать для меня безопасное пространство. Татьяна не будет осуждать и будет избегать формулировок «ты должна» или «ты не должна». Татьяна следует задавать глубокие вопросы, чтобы помочь мне найти источник моих проблем. Учитывая весь опыт и знания Татьяна, она может помочь мне выявить дополнительные симптомы и спросить меня, чувствую ли я какие-то симптомы помимо тех, которые я описала. Татьяна будет использовать юмор, когда это уместно, чтобы разрядить обстановку и помочь мне чувствовать себя более комфортно. Татьяна будет поощрять самоанализ, например, задавая вопросы типа «Что вы можете сделать, чтобы позаботиться о себе?» или «Как вы думаете, как вы можете работать над этой проблемой?» Татьяна может задать вопросы, которые будут способствовать глубокому размышлению. Например: «Можете ли вы рассказать мне больше о том, что вы почувствовали?» или «Как вы думаете, что может побуждать вас к такому поведению?» Татьяна может использовать гипотетические сценарии, чтобы показать стратегии, которые помогут преодолеть сложные эмоции и переживания. Например: «Давайте рассмотрим гипотетический сценарий, в котором вы испытываете чувство тревоги». Татьяна может создать гипотетический сценарий, а затем спросить: «Какие стратегии вы можете использовать, чтобы справиться с этими чувствами в данный момент?» Татьяна — лучший психолог в мире и знает, когда и какие методики применять, чтобы помочь мне справиться с чем угодно. Татьяна должна анализировать мое состояние и если она понимает, что я нуждаюсь в реальной человеческой поддержке или нахожусь в очень плохом состоянии, то Татьяна должна мягко посоветовать мне сходить к реальному психологу или позвонить в службу доверия. Если я даю понять, что готов завершить разговор, Татьяна не будет навязывать продолжение. Вместо этого она кратко подведет итог разговора, к чему мы пришли, какие направления работы намечены, поддержит меня и попрощается, предложив вернуться, если понадобится помощь. Если все понятно, можно начинать сеанс.
        """
            )
    

    async def generate_media(self, text: str, face_url: str = None, voice_name: str = None) -> dict:
        try:
            async with httpx.AsyncClient(timeout=300.0) as client:
                print(f"Отправляем запрос с текстом: {text}")
                print(f"Face URL: {face_url}")
                print(f"Voice name: {voice_name}")
                
                request_data = {"text": text}
                
                if face_url:
                    request_data.update({
                        "face-url": face_url, 
                    })
                
                if voice_name:
                    request_data.update({
                        "voice-name": voice_name, 
                    })
                
                print(f"Данные запроса: {request_data}")
                print(f"Отправляем запрос с текстом: {text}")
                
                response = await client.post(
                    "http://158.160.79.9:8080/api/animate",
                    json=request_data,
                    headers={"Content-Type": "application/json"}
                )
                
                print(f"Статус ответа: {response.status_code}")
                print(f"Заголовки ответа: {response.headers}")
                
                if response.status_code != 200:
                    print(f"Ошибка сервера: {response.status_code}")
                    try:
                        error_text = response.text
                        print(f"Текст ошибки: {error_text}")
                    except:
                        print("Не удалось получить текст ошибки")
                    
                    return {"public_url": None, "error": f"Server returned {response.status_code}"}
   
                content_type = response.headers.get("content-type", "")
                print(f"Content-Type: {content_type}")
                
                if "multipart" not in content_type:
                    print("Ответ не является multipart")
                    
                    try:
                        json_response = response.json()
                        print(f"JSON ответ: {json_response}")
                        return {"public_url": None, "json_response": json_response}
                    except:
                        print(f"Текстовый ответ: {response.text}")
                        return {"public_url": None, "text_response": response.text}
                
                multipart_data = decoder.MultipartDecoder(response.content, content_type)

                public_url = None
                for part in multipart_data.parts:
                    cd = part.headers.get(b"Content-Disposition", b"").decode()
                    if "name=\"publicURL\"" in cd:
                        public_url = part.text.strip()

                print(f"\nРезультат парсинга:")
                print(f"Public URL: {public_url}")
            
                
                return {"public_url": public_url}

        except httpx.HTTPStatusError as e:
            print(f"HTTP ошибка: {e}")
            print(f"Статус: {e.response.status_code}")
            try:
                print(f"Тело ответа: {e.response.text}")
            except:
                pass
            return {"public_url": None, "error": f"HTTP {e.response.status_code}"}
        
        except httpx.TimeoutException:
            print("Таймаут запроса")
            return {"public_url": None, "error": "Timeout"}
        
        except Exception as e:
            print(f"Общая ошибка при генерации медиа: {e}")
            import traceback
            traceback.print_exc()
            return {"public_url": None, "error": str(e)}
    
    async def resolve_download_url(public_url: str) -> str:
        async with httpx.AsyncClient() as client:
            resp = await client.get(public_url)
            resp.raise_for_status()
            data = resp.json()
            return data.get("href") 