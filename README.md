# Infinited Carousel CollectionView

## 스크린샷
https://github.com/user-attachments/assets/821852bb-7051-4503-b218-931353d99e36

## 기술 스택
 - UIKit
 - Combine 

## 표현 용어
 - origin : 원본 데이터                                     ex) [0, 1, 2, 3]
 - extra : 무한 스크롤을 위해 원본 앞뒤로 복사본을 추가한 데이터      ex) [3, 0, 1, 2, 3, 0]
 - carousel Index : 무한 스크롤을 위해 계산 처리한 Index

## 구현 방법
1. UICollectionViewCompositionalLayout에서 Delegate 방식으로 변경
   > visibleItemsInvalidationHandler만 사용해서는 스크롤 이벤트가 한정적이라 Delegate 방식 선택.
2. origin에서 앞뒤로 한개의 아이템만 붙여넣어 무한 스크롤 구현
   > 동작 예시 : last extra에 도달한 경우, origin first로 이동
