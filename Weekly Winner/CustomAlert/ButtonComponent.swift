//
//  ButtonComponent.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 7/23/23.
//


import SwiftUI

struct ButtonComponent: View {
    let title: String
    var anim: Bool = false
    var callback: (() -> Void)?

    var body: some View {
        if nil != callback {
            Button(action: callback!, label: {
                Text(title)
            })
            .frame(width: 120.0, height: 45.0)
            .background(Color("Color 3"))
            .foregroundColor(.white)
            .font(.title2)
            .clipShape(Capsule())
            .padding(.bottom, 10)
        }
    }
}

struct ButtonComponent_Previews: PreviewProvider {
    static var previews: some View {
        ButtonComponent(title: K.appButtonTitle.ok, callback: {
        })
    }
}

