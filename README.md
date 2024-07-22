<img src="https://github.com/user-attachments/assets/ce0d8900-fa80-4e7d-ba22-222af9e47c94" alt="이웃(Eut) Logo" width="400" height="200">
<br><br>

# 이웃
챗봇과 감정 데이터 통계를 통해 **독거노인의 마음을 채우고, 가족에게 안심을 주는 서비스**
<br><br>


## 환경
인터넷 연결이 되어있어야 함. <br>
안드로이드 11.0 OS이 실행되는 모바일 기기 <br>
iOS 13.0 이상이 실행되는 모 바일 기기
<br><br>


## 프로그래밍
- Python: 데이터 처리, 모델 구현 및 Flask 서버 연동 (3.11.5)  -> 수정해야
- Java: 백엔드 서버 개발 (JDK 17)  -> 수정해야
- Dart: Flutter를 통한 프론트엔드 개발
- MySQL: 데이터베이스 관리 (8.3.0)  -> 수정해야
<br><br>


## 프레임워크  -> 수정해야
- Flutter: 모바일 애플리케이션 UI 개발
- Spring Boot: Java 기반의 백엔드 서버 프레임워크
- Flask: Python 기반, 모델 실행을 위한 프레임워크 (3.0.3)
- YOLOv5: 객체 탐지 모델 (7.0)
- PyTorch: 머신러닝 모델 구현 및 학습 (2.3)
- AWS (Amazon Web Services): 서버 호스팅 및 클라우드 서비스, 어플의 배포를 위함 (2023.2)
<br><br>


## 목차
1. 주제 선정 배경
2. 서비스 소개
3. 기술 소개
4. 기대효과 
<br><br>


### 주제 선정 배경
독거노인의 현 상황을 종합적으로 분석해 본 결과, 연령이 높아질수록 사회적 고립도가 증가하는 경향이 있었습니다. <br>
현재 정부는 '노인맞춤돌봄서비스'를 시행 중이지만, 독거노인 수에 비해 이 서비스의 제공이 매우 부족한 상황입니다. 전문가들은 독거노인의 고립과 단절 문제에 대한 사회적 관심을 더욱 강조하고 있습니다. <br>
따라서 우리는 독거노인들이 자신의 상황을 부정적으로 인식하는 경우를 위한 일상생활 지원 서비스를 개발하고 강화함으로써 이들의 삶의 질을 향상시키기 위해 이러한 서비스를 기획했습니다.
<br><br>


### 서비스 소개

##### User 1. 독거노인   <img src="https://github.com/user-attachments/assets/6121fc1b-a829-464f-8330-5e80a3955ba9" alt="elder" width="30" height="30"> <br>
독거노인의 메인 기능은 챗봇입니다. <br><br>
<img src="https://github.com/user-attachments/assets/1e7750f3-5997-4ac6-a308-34896af0172e" alt="chatbot" width="300" height="200"> <br>
사용자화된 챗봇은 독거노인에게 먼저 안부를 물어 대화를 시작합니다. 사용자는 녹음 기능으로 이에 답하며 자연스럽게 대화를 이어나갈 수 있습니다. <br>
<br><br>
<img src="https://github.com/user-attachments/assets/9f9db688-e544-40cf-b887-d78030d7c640" alt="chatbot" width="400" height="200"> 
&nbsp;&nbsp;&nbsp;
<img src="https://github.com/user-attachments/assets/5a99b01e-faae-4b06-afcc-1a6c2276efa7" alt="chatbot" width="400" height="200"> <br>
챗봇은 7가지의 감정을 표현할 수 있습니다. 사용자의 발화를 분석하여 가장 적합한 감정을 선택하고 해당 감정의 이미지를 표시합니다.
<br><br>

##### User 2. 부양가족   <img src="https://github.com/user-attachments/assets/e601f3a5-db45-408c-974f-b26cd5ea4300" alt="elder" width="50" height="30"> <br>
부양가족은 1일, 1주일, 1개월 단위로 독거노인과 챗봇 간의 대화 내용 요약과 감정 데이터 통계를 확인할 수 있습니다. <br><br>
<img src="https://github.com/user-attachments/assets/d41058c4-538f-472f-996f-876af1318ea0" alt="statistics_daily" width="300" height="200"> 
&nbsp;&nbsp;&nbsp;
<img src="https://github.com/user-attachments/assets/335b199e-5b97-4b1e-b738-7668952918bf" alt="statistics_weekly" width="200" height="200"> 
&nbsp;&nbsp;&nbsp;
<img src="https://github.com/user-attachments/assets/bfe41600-f71a-4e8b-8ea5-d8ed76782544" alt="statistics_monthly" width="250" height="200"> 
<br><br>


### 주요 기능과 구성 요소
1. 챗봇<br>
서버에서 푸시 알림을 보내어 사용자가 앱에 접속하도록 유도하며 적절한 문구로 사용자에게 인사를 건넵니다. 독거노인 사용자가 녹음 기능을 통해 답변하면, STT 기술을 사용해 사용자의 음성을 인식합니다. 이후 TTS를 활용해 해당 답변을 텍스트로 변환합니다. <br>
이후, 감성 분석 모델을 통해 사용자의 감정을 7가지로 분류하여 분석한 후, 챗봇은 가장 대표적인 감정의 표정을 나타내고 적절한 질문을 다시 건넵니다.<br>
이 과정을 반복하며 챗봇은 사용자와 자연스러운 일상 대화를 이어갑니다.<br>
2. 대화내용 요약<br>
SKT-AI에서 배포한 KoBart 모델을 활용하여 사용자와 챗봇 간의 대화 내용을 요약합니다.<br>
3. 감정 데이터 통계<br>
SKT Brain에서 배포한 KoBERT 모델을 활용하여 사용자가 챗봇과 나눈 대화를 분석하고, 감정을 7가지 카테고리로 분류합니다. <br>
이 분석 결과를 기반으로 부양가족 사용자가 일일, 주간, 월간 단위로 감정 데이터 통계를 확인할 수 있도록 제공합니다.
<br><br>
##### 작업 흐름 요약  --> 백엔드 서버도 언급하면서 적절히 수정
(선택) 푸쉬 알림을 보내어 독거노인 사용자가 앱을 사용하도록 유도
챗봇이 독거노인에게 적절한 문구로 안부를 물음
독거노인은 이에 답변
음성 데이터를 텍스트로 변환하여 사용자의 감정을 분석하고 대화 내용 요약

### 기대 효과
- 독거노인의 정서 상태를 파악하고 그들을 위한 프로그램 및 상담 등의 지원을 제공하기 위해 가정, 요양원, 지역 커뮤니티 센터, 사회복지 기관 등 다양한 장소에서 이 서비스를 활용할 수 있습니다.<br>
- 또한, 독거노인은 이러한 서비스를 통해 우울감을 해소하고 사회적 고립감을 완화할 수 있습니다. 부양가족은 독거노인이 서비스를 이용함으로써 실시간으로 건강 상태를 모니터링할 수 있으며, 통계를 통해 효율적인 돌봄 계획을 수립할 수 있습니다. 이로 인해 가족 간의 교류가 활성화되고 유대감이 깊어질 수 있습니다.
