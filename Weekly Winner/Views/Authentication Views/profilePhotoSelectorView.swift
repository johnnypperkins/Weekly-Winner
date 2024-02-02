//
//  profilePhotoSelectorView.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 8/16/23.
//


import SwiftUI
import Firebase

private enum FocusableFieldProfileData: Hashable {
    case username
    case instagram
    case promoCode
    case birthday
}
   
struct profilePhotoSelectorView: View {
    
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var profileImage: Image?
    @ObservedObject var viewModel: authenticationViewModel
    @State private var collegeName: String = ""
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @FocusState private var focus: FocusableFieldProfileData?
    
    @State var selectedState = "Choose here"
    @State var age: Int?
    @State var country: String = "Choose here"
    @State private var selectedGender = "unavailable"
    @State var username = ""
    @State var instagram = ""
    @State var promoCode = ""
    @State var selectedDay = 1
    @State var selectedMonth = 1
    @State var selectedYear = ""
    @State private var isPickerPresented = false
    
    let states = [
            "Choose here","Alabama", "Alaska", "Arizona", "Arkansas", "California",
            "Colorado", "Connecticut", "Delaware", "Florida", "Georgia",
            "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas",
            "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts",
            "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana",
            "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico",
            "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma",
            "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota",
            "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington",
            "West Virginia", "Wisconsin", "Wyoming"
        ]
    let countries = [ "Choose here", "United States of America" ]
    
    init(model: authenticationViewModel) {
        viewModel = model
    }
    
    var body: some View {
        ZStack {
            K.finalColor.backgroundBlue
            NavigationStack{
                
                VStack{
                    
                    Text("Complete Your Profile!")
                        .font(Font.custom(K.customFonts.lexendDecaSB, size: 24).weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.top)
                    HStack{
                        Text("Everything with a ")
                            .font(Font.custom(K.customFonts.lexendDecaLight, size: 12).weight(.light))
                            .foregroundColor(.white)
                        
                        Text("*")
                            .font(Font.custom(K.customFonts.lexendDecaLight, size: 14).weight(.light))
                            .foregroundColor(.red)
                        
                        Text(" is mandatory.")
                            .font(Font.custom(K.customFonts.lexendDecaLight, size: 12).weight(.light))
                            .foregroundColor(.white)
                        
                    }.padding(.bottom)
                        .padding(.horizontal,16)
                    ScrollView {
                        ScrollViewReader { scrollProxy in
                            VStack{
                                VStack {
                                    
                                    VStack(alignment: .center){
                                        if let profileImage = profileImage {
                                            profileImage
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 100, height: 100)
                                                .clipShape(Circle())
                                                .onTapGesture {
                                                    showImagePicker.toggle()
                                                }
                                        }
                                        else {
                                            ZStack {
                                                
                                                
                                                Image(systemName: "person.circle")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 100, height: 100)
                                                    .clipShape(Circle())
                                                    .foregroundColor(.white)
                                                    .opacity(0.66)
                                                    .onTapGesture {
                                                        showImagePicker.toggle()
                                                    }
                                                
                                                HStack {
                                                    Text("*")
                                                        .font(Font.custom(K.customFonts.lexendDecaLight, size: 14).weight(.light))
                                                        .foregroundColor(.red)
                                                    Text("Profile Picture")
                                                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                                                        .foregroundColor(.black)
                                                    Text("*")
                                                        .font(Font.custom(K.customFonts.lexendDecaLight, size: 14).weight(.light))
                                                        .foregroundColor(.red)
                                                }
                                                .frame(width: 150)
                                                .background(.white.opacity(0.75))
                                                .cornerRadius(5)
                                            }
                                        }
                                    }.padding()
                                        .sheet(isPresented: $showImagePicker,
                                               onDismiss: loadImage) {
                                            imagePicker(image: $selectedImage)
                                        }
                                               .padding(.top)
                                               .padding(.bottom)
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack {
                                            Text("Username")
                                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                                                .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                                            Text("*")
                                                .font(Font.custom(K.customFonts.lexendDecaLight, size: 14).weight(.light))
                                                .foregroundColor(.red)
                                            if username != "" {
                                                Text((username.contains(" ") || username.containsEmoji()) ? "Invalid Username" : (viewModel.usernameTaken ? "Username Taken" : "Username Available"))
                                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14).weight(.medium))
                                                    .foregroundColor((viewModel.usernameTaken || username.contains(" ") || username.containsEmoji()) ? K.finalColor.deleteRed : K.finalColor.winningGreen)
                                                    .padding(.leading, 5)
                                            }
                                            
                                        }
                                        
                                        HStack() {
                                            TextField("Username", text: $username)
                                     
                                            .onChange(of: username) { newUsername in
                                                username = newUsername.lowercased()
                                                viewModel.checkUsernameAvailability(potentialUsername: username) {}

                                            }
                                            .placeholder(when: username.isEmpty, placeholder: {
                                                Text("Username").foregroundColor(.gray)
                                            })
                                            .foregroundColor(.white)
                                            .font(Font.custom(K.customFonts.lexendDecaLight, size: 14))
                                            .accentColor(.white)
                                            .textInputAutocapitalization(.none)  // Consider changing this to .none if you always want lowercase
                                            .disableAutocorrection(true)
                                            .focused($focus, equals: .username)
                                            .submitLabel(.next)
                                            .onSubmit {
                                                withAnimation {
                                                    self.focus = .instagram
                                                }
                                            }

                                            
                                        }
                                        .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 15))
                                        .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                                        .cornerRadius(15)
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                                    .id(FocusableFieldProfileData.username)
                                    .padding(.horizontal,16)
                                    
                                    HStack {
                                        Text("Country")
                                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                                            .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                                        Text("*")
                                            .font(Font.custom(K.customFonts.lexendDecaLight, size: 14).weight(.light))
                                            .foregroundColor(.red)
                                        
                                        Spacer()
                                        Picker("Select a Country", selection: $country) {
                                            ForEach(countries, id: \.self) { country in
                                                Text(country)
                                            }
                                        }
                                        .pickerStyle(DefaultPickerStyle())
                                        
                                        
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 40, maxHeight: 40)
                                    .padding(.horizontal,16)
                                    
                                    HStack {
                                        Text("State")
                                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                                            .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                                        
                                        //                    Text("(if residing in the USA):")
                                        //                        .font(Font.custom(K.customFonts.lexendDecaLight, size: 12).weight(.light))
                                        //                        .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                                        //                        .padding(.trailing,10)
                                        Text("*")
                                            .font(Font.custom(K.customFonts.lexendDecaLight, size: 14).weight(.light))
                                            .foregroundColor(.red)
                                        Spacer()
                                        Picker("Select a state", selection: $selectedState) {
                                            ForEach(states, id: \.self) { state in
                                                Text(state)
                                            }
                                        }.onTapGesture {
                                            withAnimation {
                                                self.focus = nil
                                                self.isPickerPresented = false
                                            }
                                        }
                                        .pickerStyle(DefaultPickerStyle())
                                        
                                        
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 40, maxHeight: 40)
                                    .padding(.horizontal,16)
                                    
                                    HStack{
                                        Text("Birthday")
                                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                                            .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                                        Text("*")
                                            .font(Font.custom(K.customFonts.lexendDecaLight, size: 14).weight(.light))
                                            .foregroundColor(.red)
                                        Spacer()
                                        ZStack{
                                            
                                            
                                            if isPickerPresented {
                                                CustomDatePicker(day: $selectedDay, month: $selectedMonth, year: $selectedYear)
                                                    .id(FocusableFieldProfileData.birthday)
                                                    .focused($focus, equals: .birthday)
                                            }else{
                                                Button(action: {
                                                    withAnimation{
                                                        self.isPickerPresented.toggle()
                                                        self.focus = .birthday
                                                    }
                                                }) {if selectedYear == "" {
                                                    Text("\(formattedDate(Date()))")
                                                        .foregroundColor(.white)
                                                        .padding(8)
                                                }
                                                    else{
                                                        Text("\(selectedMonth)/\(selectedDay)/\(selectedYear)")
                                                            .foregroundColor(.white)
                                                            .padding(8)
                                                    }
                                                }.background(K.finalColor.cardBlue)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                                
                                                
                                            }
                                        }
                                        
                                    }.padding(.horizontal,16)
                                    
                                    //                .id(FocusableFieldSignup.username)
                                    HStack{
                                        Text("Sex:")
                                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                                            .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                                        Spacer()
                                        
                                        Picker("Sex", selection: $selectedGender) {
                                            Text("Choose here").tag("unavailable")
                                            Text("Male").tag("Male")
                                            Text("Female").tag("Female")
                                        }.onTapGesture {
                                            withAnimation {
                                                self.focus = nil
                                                self.isPickerPresented = false
                                            }
                                        }
                                        
                                    }.padding(.horizontal,16)
                                        .padding(.top,5)
                                    
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Instagram")
                                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                                            .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                                        HStack() {
                                            TextField("Instagram", text: $instagram)
                                                .placeholder(when: instagram
                                                    .isEmpty, placeholder: {
                                                        Text("Instagram").foregroundColor(.gray)
                                                    })
                                                .foregroundColor(.white)
                                                .font(Font.custom(K.customFonts.lexendDecaLight, size: 14))
                                                .accentColor(.white)
                                                .textInputAutocapitalization(.words)
                                                .disableAutocorrection(true)
                                                .focused($focus, equals: .instagram)
                                                .submitLabel(.next)
                                                .onSubmit {
                                                    withAnimation {
                                                        self.focus = .promoCode
                                                    }
                                                }
                                            
                                        }
                                        .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 15))
                                        .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                                        .cornerRadius(15)
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                                    .id(FocusableFieldProfileData.instagram)
                                    .padding(.horizontal,16)
                                    
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Promo Code")
                                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                                            .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                                        HStack() {
                                            TextField("Promo Code", text: $promoCode)
                                                .placeholder(when: promoCode
                                                    .isEmpty, placeholder: {
                                                        Text("Promo Code").foregroundColor(.gray)
                                                    })
                                                .foregroundColor(.white)
                                                .font(Font.custom(K.customFonts.lexendDecaLight, size: 14))
                                                .accentColor(.white)
                                                .keyboardType(.emailAddress)
                                                .textInputAutocapitalization(.words)
                                                .disableAutocorrection(true)
                                                .focused($focus, equals: .promoCode)
                                                .submitLabel(.next)
                                                .onSubmit {
                                                    withAnimation {
                                                        self.focus = nil
                                                    }
                                                }
                                            
                                            
                                        }
                                        .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 15))
                                        .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                                        .cornerRadius(15)
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                                    .id(FocusableFieldProfileData.promoCode)
                                    .padding(.horizontal,16)
                                    
                                    
                                    Spacer()
                                }
                            } .padding(.bottom, focus == nil ? 0 : 300)
                                .onChange(of: focus) { newFocus in
                                    //                    if newFocus == .password {
                                    withAnimation {
                                        scrollProxy.scrollTo(newFocus, anchor: .top)
                                    }
                                    //                    }
                                }
                        }
                        
                        
                        Spacer()
                    }.frame(height: 550)
                    
                    if let selectedImage = selectedImage {
                        if country != "Choose here" && selectedYear != "" && selectedState != "Choose here" && username != "" && !viewModel.usernameTaken && !username.contains(" ") && !username.containsEmoji(){
                            NavigationLink(destination: {
                                TermsAndConditionsView(viewModel: viewModel) },label: {
                                    HStack{
                                        Spacer()
                                        
                                        Text("Continue")
                                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                                            .foregroundColor(.white)
                                        //shadow
                                        
                                        Spacer()
                                    }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 56 , maxHeight: 56)
                                        .background(Color(red: 0.31, green: 0.57, blue: 1))
                                        .cornerRadius(10)
                                        .padding(.horizontal,16)
                                        .padding(.bottom,30)
                                })
                            .simultaneousGesture(TapGesture().onEnded{
                                viewModel.uploadProfileImage(selectedImage)
                                if let date = createDate(day: selectedDay, month: selectedMonth, year: Int(selectedYear) ?? 0) {
                                    viewModel.uploadSupplementaryData(country: country, birthday: date, state: selectedState, gender: selectedGender, username: username, instagram: instagram, promoCode: promoCode)
                                    print(date)
                                }
                                Task{
                                    await wait()
                                }
                            })
                        } else {
                            HStack{
                                Spacer()
                                if username.contains(" ") || username.containsEmoji() {
                                    Text("Invalid Username")
                                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                                        .foregroundColor(.white)
                                } else if viewModel.usernameTaken {
                                    Text("Username Taken")
                                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                                        .foregroundColor(.white)
                                } else {
                                    Text("Fill All Fields")
                                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                                        .foregroundColor(.white)
                                }
                                
                                //shadow
                                
                                Spacer()
                            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 56 , maxHeight: 56)
                                .background(K.finalColor.deleteRed)
                                .cornerRadius(10)
                                .padding(.horizontal,16)
                                .padding(.bottom,30)
                                .opacity(0.66)
                        }
                    } else {
                        HStack{
                            Spacer()
                            
                            Text("Fill All Fields")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                                .foregroundColor(.white)
                            //shadow
                            
                            Spacer()
                        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 56 , maxHeight: 56)
                            .background(K.finalColor.deleteRed)
                            .cornerRadius(10)
                            .padding(.horizontal,16)
                            .padding(.bottom,30)
                            .opacity(0.66)
                    }
                }
                
                
            }.navigationBarBackButtonHidden(true)
                .frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity)
                .background(Color(red: 0.02, green: 0.05, blue: 0.26))
                .ignoresSafeArea()
                .padding(.top, 50)
        }
    }
    
    func loadImage() {
        guard let selectedImage = selectedImage else {return}
        profileImage = Image(uiImage: selectedImage)
    }
    
    private func wait() async {
        do {
            print("Wait")
            try await Task.sleep(nanoseconds: 4_000_000_000)
            print("Done")
        }
        catch { }
    }
    func formattedDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter.string(from: date)
        }
}


func createDate(day: Int, month: Int, year: Int) -> Date? {
    var dateComponents = DateComponents()
    dateComponents.day = day
    dateComponents.month = month
    dateComponents.year = year

    // Use the current calendar or specify a calendar
    let calendar = Calendar.current
    return calendar.date(from: dateComponents)
}

struct CustomDatePicker: View {
    @Binding var day: Int
    @Binding var month: Int
    @Binding var year: String

    private var months: [String] { Calendar.current.shortMonthSymbols }
    private var days: [Int] { (1...31).map { $0 } }
    let years = [
    "1930","1931","1932","1933","1934","1935","1936","1937","1938","1939",
    "1940","1941","1942","1943","1944","1945","1946","1947","1948","1949",
    "1950","1951","1952","1953","1954","1955","1956","1957","1958","1959",
    "1960","1961","1962","1963","1964","1965","1966","1967","1968","1969",
    "1970","1971","1972","1973","1974","1975","1976","1977","1978","1979",
    "1980","1981","1982","1983","1984","1985","1986","1987","1988","1989",
    "1990","1991","1992","1993","1994","1995","1996","1997","1998","1999",
    "2000","2001","2002","2003","2004","2005","2006"
    ]

    var body: some View {
        HStack {
            Picker(selection: $day, label: Text("Day")) {
                ForEach(days, id: \.self) {
                    Text("\($0)").foregroundColor(.white)
                }
            }
            .pickerStyle(WheelPickerStyle())

            Picker(selection: $month, label: Text("Month")) {
                ForEach(1..<months.count + 1, id: \.self) {
                    Text(months[$0 - 1]).foregroundColor(.white)
                }
            }
            .pickerStyle(WheelPickerStyle())

            Picker(selection: $year, label: Text("Year")) {
                ForEach(years, id: \.self) { number in
                    Text("\(number)").foregroundColor(.white)
                        .tag(number)
                }
            }
            .pickerStyle(WheelPickerStyle())
        }
    }
}

private extension Date {
    var year: Int {
        get { Calendar.current.component(.year, from: self) }
        set {
            if let newDate = Calendar.current.date(bySetting: .year, value: newValue, of: self) {
                self = newDate
            }
        }
    }

    var month: Int {
        get { Calendar.current.component(.month, from: self) }
        set {
            if let newDate = Calendar.current.date(bySetting: .month, value: newValue, of: self) {
                self = newDate
            }
        }
    }

    var day: Int {
        get { Calendar.current.component(.day, from: self) }
        set {
            if let newDate = Calendar.current.date(bySetting: .day, value: newValue, of: self) {
                self = newDate
            }
        }
    }
}


