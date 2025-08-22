//
//  FiltersView.swift
//  ch2 app 2pm
//
//  Created by T Krobot on 16/8/25.
//

import SwiftUI

struct FiltersView: View {
    var body: some View {
        NavigationStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .navigationTitle("Filters")
            Spacer()
            NavigationLink(destination: FinalProductView()) {
                Text("Final Product")
            }
        }
    }
}

#Preview {
    FiltersView()
}
