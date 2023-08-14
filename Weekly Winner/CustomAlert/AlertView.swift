//
//  AlertView.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 7/23/23.
//


import SwiftUI

enum AlertAction {
    case ok
    case cancel
    case others
}

enum AlertButtonAction {
    case okButton
    case cancelButton
}

enum AlertType {
    case success, error, info, none
    
    var image:UIImage {
        switch self {
        case .success:
            return UIImage(named: K.imgNames.success)!
        case .error:
            return UIImage(named: K.imgNames.warning)!
        case .none:
            return UIImage(named: "Logo")!
        default:
            return UIImage(named: K.imgNames.info)!
        }
    }
    
}

typealias AlertButtonActionCompletion = ((_ action: AlertButtonAction) -> Void)

struct CustomAlertView: View {
    var alertType:AlertType = .success
    var title:String
    var message:String
    var isShowCancel: Bool = false
    var actionButtonTitle:String?
    var cancelButtonTitle:String = K.appButtonTitle.ok
    var buttonActionCompletion:AlertButtonActionCompletion?
    @State var height : CGFloat = 0.0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack {
                if alertType == .none {
                    Text("WagerPool")
                        .font(Font.custom(K.customFonts.lexendDecaSB, size: 25).weight(.semibold))
                        .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                        .padding(.top, 15)
                }
                else {
                    Text(title)
                        .font(.title)
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(height: 50)
                        .padding([.top, .leading, .trailing], 15)
                }
                
                Spacer()
                GeometryReader { reader in
                    ScrollView {
                        Text(message)
                            .font(Font.custom(K.customFonts.lexendDecaLight, size: 14))
                            .foregroundColor(.white)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(width: reader.size.width-50, height: 100)
                            .padding(15)
                    }
                    .frame(width: reader.size.width)
                }
                Spacer()
                HStack {
                    Spacer()
                    if actionButtonTitle != nil {
                        ButtonComponent(title: actionButtonTitle ?? K.appButtonTitle.ok) {
                            buttonActionCompletion?(.okButton)
                        }
                    }
                    ButtonComponent(title: cancelButtonTitle) {
                            buttonActionCompletion?(.cancelButton)
                        
                        
                    }
                    Spacer()
                }
            }
            .background(Color(red: 0.13, green: 0.14, blue: 0.34))
            .frame(width: UIScreen.main.bounds.width-50, height: 280)
            .cornerRadius(10)
            .clipped()
            
        }
    }
    
//    func getHeight(msg : String) -> CGFloat {
//        DispatchQueue.main.async {
//            height = msg.textHeightFrom(width: UIScreen.main.bounds.width-50, fontName: FontStyle.Montserrat_Medium.rawValue, fontSize: 14)
//        }
//        return height
//    }
}

struct CustomAlertView_Previews: PreviewProvider {
    static var previews: some View {
        CustomAlertView(alertType: .none, title: "Title", message: "Text Message", actionButtonTitle: "Submit", cancelButtonTitle: "Cancel", buttonActionCompletion: { action in
            print(action)
        })
    }
}
