//
//  TapTap.swift
//  ChopstickGame
//
//  Created by hurdasol on 2022/06/09.
//
import Foundation
import SwiftUI
import UIKit

struct BeforeTap: View{
    var body: some View{
        NavigationView{
            VStack{
                //추후 추가될 이미지
                Image("HiBear")
                    .resizable()
                    .scaledToFit()
                //설명란
                VStack(alignment: .leading){
                    Text("시작하고 3초후 5초간 화면을 탭해주세요!")
                    Text("가장많이 탭한 사람이 승리합니다!")
                }.frame(width: 354, height:192)
                    .font(.custom("Happiness-Sans-Regular", size: 17))
                    .background(Color("TrolIvory"))
                //시작하기 버튼
                NavigationLink {
                    TapTap()
                } label: {
                    Text("시작하기")
                        .foregroundColor(.white)
                        .font(.custom("Happiness-Sans-Bold", size: 17))
                        .bold()
                        .frame(width: 354, height: 54)
                        .background(Color("TrolGreen"))
                        .cornerRadius(7)
                }
            }
        }.navigationTitle("탭탭!")
    }
}
struct TapTap: View {
    
    @State private var CountTap = 0 //누른 횟수
    
    @State private var isGameEnd: Bool = false
    @State private var isGameStart: Bool = false
    
    //타임 매니저 사용
    @State private var timeRemaining = 5 //게임 남은 시간
    @State private var startTime = 3 //게임 시작되는 시간
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    //화면의 크기를 받아옴
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack{
            VStack(alignment: .center,spacing: 60){
                //탭탭 제목
                Text("탭탭!")
                    .foregroundColor(Color("TrolGreen"))
                    .font(.custom("Happiness-Sans-Bold", size: 28))
                    .bold()
                    .background(Image("Cloud")
                        .resizable().frame(width: 261, height: 90))
                    .padding(.top, 100)
                
                //남은시간
                VStack(spacing: 11){
                    //아무데나 탭하세요
                    Text(startTime >= 1 ? "\(startTime)초 뒤에 게임이 시작해요" : "아무데나 탭하세요")
                        .foregroundColor(.black)
                        .onReceive(timer){_ in
                            startTime -= 1
                        }
                    Text(startTime >= 1 ? "" : "남은 시간 ")
                        .font(.custom("Happiness-Sans-Bold", size: 17))
                    
                    ZStack(alignment:.center){
                        Image("ClockFrame")
                        Text(startTime >= 1 ? "\(startTime)" : "\(timeRemaining)")
                            .font(.system(size: 50))
                            .onReceive(timer){_ in
                                if isGameStart{
                                    timeRemaining -= 1
                                    if timeRemaining == 0{
                                        isGameEnd = true
                                    }
                                }
                            }
                    }
                }.foregroundColor(Color("TrolGreen"))
                Spacer()
                //게임 탭 한 횟수 표시
                VStack(alignment: .center){
                    Text("내가 탭한 횟수")
                        .font(.custom("Happiness-Sans-Title", size: 17))
                        .padding(.top)
                    Text("\(CountTap)")
                        .font(.custom("Happiness-Sans-Title", size: 120))
                    
                    NavigationLink(destination:AfterGame(CountTap: CountTap),isActive: $isGameEnd, label: {
                        Text("")
                    })
                }.foregroundColor(Color("TrolGreen"))
                    .frame(width: 354, height:192)
                
                    .background(Color("TrolIvory"))
                    .padding(.bottom)
                
                
            }//vstack
            .navigationBarHidden(true)
            .onAppear(perform: {
                DispatchQueue.main.asyncAfter(deadline: .now()+3){
                    print("Start~")
                    isGameStart = true                }
            })
            .contentShape(Rectangle()).ignoresSafeArea(.all) //전체 화면 터치
            .onTapGesture {
                if isGameStart{
                    CountTap += 1   //화면 터치시 CountTap +1
                }
            }
        }//zstack
                
        
    }
}
    //게임이 끝나고 결과 확인
    struct AfterGame:View{
        //임시 유저
        @StateObject var tempUsers = TempUsers()
        var CountTap: Int
        @State private var confirmResult :Bool = false
        var body: some View{
            VStack{
                Text("탭탭!")
                    .foregroundColor(Color("TrolGreen"))
                    .font(.custom("Happiness-Sans-Bold", size: 28))
                    .bold()
                    .background(Image("Cloud")
                        .resizable().frame(width: 261, height: 90))
                    .padding(.top, 100)
                    .padding(.bottom, 50)
                HStack(alignment:.top, spacing:75){
                    VStack{
                        Spacer().frame(height:25)
                        Text("내가 탭한 횟수")
                            .font(.custom("Happiness-Sans-Title", size: 17))
                    }
                    Text("\(CountTap)")
                        .font(.custom("Happiness-Sans-Title", size: 120))
                }.foregroundColor(Color("TrolGreen"))
                
                    .frame(width:354,height:146)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color("TrolIvory")))
                VStack{
                    HStack{
                        Text("랭킹 살펴보기")
                            .padding()
                            .font(.custom("Happiness-Sans-Title", size: 28))
                        Spacer()
                    }
                    
                    List{
                        
                        ForEach(tempUsers.sortedRank.indices, id: \.self){index in
                            HStack(spacing:15){
                                Text("\(index + 1)")
                                Text(tempUsers.sortedRank[index].name)
                                Spacer()
                                Text("\(tempUsers.sortedRank[index].countTap)")
                            }
                            .foregroundColor(tempUsers.sortedRank[index].name == "오션" ? Color("TrolGreen") : Color.black)
                        }.font(.custom("Happiness-Sans-Regular", size: 17))
                        
                    }.listStyle(.inset)
                    
                }.onAppear(){
                    for index in tempUsers.tempRank.indices{
                        if tempUsers.tempRank[index].name == "오션" {
                            tempUsers.tempRank[index].countTap = CountTap
                        }
                    }
                }
                Spacer()
                
                //다음으로 가기
                NavigationLink(destination: GameResult(),isActive: $confirmResult, label:{
                    Text("")})
                //선택하러 가기 버튼
                Button(action: {
                    confirmResult = true
                }, label:{
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("TrolGreen"))
                        .frame(width: 354, height: 50)
                        .overlay(
                            Text("선택하러 가기")
                                .foregroundColor(Color.white)
                                .bold()
                        )
                    
                })
                
            }//vstack
            .navigationBarHidden(true)
            
            
            
        }
    }
    //순위대로 역할 선택하기 //추후 버킬코드로 갈아 끼울 예정
    struct GameResult: View{
        @State private var tempRole = ["총무", "드라이버", "광대", "요리사"]
        var columns: [GridItem] = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        var body: some View{
            
            ScrollView{
                VStack{
                    HStack(alignment: .center, spacing: 200) {
                        Text("역할 선택하기")
                            .font(.custom("Happiness-Sans-Bold", size: 22))
                        
                        
                        Button {
                            print("add this area later")
                        } label: {
                            Image(systemName: "info.circle")
                                .foregroundColor(Color("TrolGreen"))
                        }
                        
                    }
                    HStack {
                        VStack(alignment: .leading) {
                            Text("각 역할들의 디테일이 궁금할 땐?")
                                .font(.custom("Happiness-Sans-Bold", size: 12))
                            
                            HStack {
                                Image(systemName: "info.circle")
                                    .font(Font.subheadline.weight(.light))
                                
                                Text("를 클릭하면 역할 도감을 볼 수 있어요!")
                                    .font(.custom("Happiness-Sans-Regular", size: 12))
                                    .offset(x: -8)
                            }
                        }
                        
                        Spacer()
                        
                        Text("👀")
                    }
                    .padding()
                    .background(Color("TrolIvory"))
                    .cornerRadius(10)
                    
                    
                    LazyVGrid(columns: columns, alignment: .center, spacing: 20){
                        ForEach(tempRole, id:\.self){i in
                            Button(action: {
                                
                            }, label: {
                                ZStack(alignment:.bottomLeading){
                                    Image("HiBear").resizable()
                                        .frame(width: 150)
                                    
                                    Text(i)
                                        .padding()
                                        .foregroundColor(.black)
                                }
                            })
                        }
                    }
                }
            }.navigationBarHidden(true)
        }
    }
    
    struct TapTap_Previews: PreviewProvider {
        static var previews: some View {
                                    BeforeTap()
//            TapTap()
            //        AfterGame(CountTap: 3)
            //        GameResult()
        }
    }
    
    
    //임시 데이터 모델
    
    //임시 유저, 이름과 탭한 횟수를 받아옴
    struct TempUserRank {
        var name: String
        var countTap: Int
    }
    //임시 사람들
    class TempUsers: ObservableObject{
        @Published var tempRank = [
            TempUserRank(name: "밀키", countTap: 34),
            TempUserRank(name: "준", countTap: 22),
            TempUserRank(name: "버킬", countTap: 28),
            TempUserRank(name: "오션", countTap: 32),
            TempUserRank(name: "린다", countTap: 11),
            TempUserRank(name: "데일", countTap: 18)
        ]
        //countTap에 따라 순위를 다시 재설정함
        var sortedRank: [TempUserRank] {
            get {
                tempRank.sorted(by: { $0.countTap > $1.countTap })
            }
            set {
                tempRank = newValue
            }
        }
    }
