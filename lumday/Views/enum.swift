//
//  enum.swift
//  lumday
//
//  Created by Ml bench-iOS Dev on 8/19/25.
//


import SwiftUI

// 1) Your options as an enum
enum CutMode: String, CaseIterable, Identifiable {
    case outline = "CoreML"
    case fillGreen = "Saliency"
    case cutout = "Enzy"

    var id: Self { self }
    var icon: String {
        switch self {
        case .outline:   return "pencil.and.outline"
        case .fillGreen: return "paintbrush.fill"
        case .cutout:    return "scissors"
        }
    }
}

// 2) A single radio row
struct RadioRow<Option: Identifiable & Hashable & CustomStringConvertible>: View {
    let option: Option
    @Binding var selection: Option

    var body: some View {
        Button {
            selection = option
        } label: {
            HStack(spacing: 12) {
                // Radio circle
                ZStack {
                    Circle()
                        .stroke(lineWidth: 2)
                        .foregroundStyle(selection == option ? Color.accentColor : Color.secondary)
                        .frame(width: 22, height: 22)
                    if selection == option {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 12, height: 12)
                    }
                }
                Text(option.description)
                    .foregroundStyle(.primary)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(option.description))
        .accessibilityAddTraits(selection == option ? .isSelected : [])
    }
}

// 3) Convenience conformance for enum -> description from rawValue
extension CutMode: CustomStringConvertible {
    var description: String { rawValue }
}

// 4) A generic radio group for any enum that is CaseIterable + Hashable + Identifiable
struct RadioGroup<Option: CaseIterable & Identifiable & Hashable & CustomStringConvertible>: View where Option.AllCases: RandomAccessCollection {
    @Binding var selection: Option
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            ForEach(Array(Option.allCases)) { option in
                RadioRow(option: option, selection: $selection)
            }
        }
        .padding()
        .background(Color.white, in: RoundedRectangle(cornerRadius: 14))
        .compositingGroup()
        .shadow(radius: 4)
    }
}

// 5) Example usage
struct RadioDemoView: View {
    @State private var mode: CutMode = .fillGreen

    var body: some View {
        VStack(spacing: 20) {
            RadioGroup<CutMode>(selection: $mode, title: "Processing Mode")

            // Show current choice
            HStack {
                Image(systemName: mode.icon)
                Text("Selected: \(mode.rawValue)")
            }
            .font(.subheadline)
            .padding(.top, 6)

            Spacer()
        }
        .padding()
        .navigationTitle("Radio Buttons")
    }
}

#Preview {
 RadioDemoView()
}
