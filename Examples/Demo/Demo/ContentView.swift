import SwiftUI

struct ContentView: View {
  @State private var showTextSelectionTest = false
  
  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
        // Text Selection Test Button (outside of Form)
        Button(action: {
          showTextSelectionTest = true
        }) {
          HStack {
            Label("Text Selection Test", systemImage: "text.cursor")
              .font(.headline)
            Spacer()
            Image(systemName: "chevron.right")
              .foregroundColor(.secondary)
          }
          .padding()
          .background(Color(.systemBackground))
        }
        .buttonStyle(PlainButtonStyle())
        .overlay(
          Rectangle()
            .frame(height: 1)
            .foregroundColor(Color(.systemGray4)),
          alignment: .bottom
        )
        
        // Main Form with existing content
        Form {
        Section("Formatting") {
          NavigationLink {
            HeadingsView()
              .navigationTitle("Headings")
              .navigationBarTitleDisplayMode(.inline)
          } label: {
            Label("Headings", systemImage: "textformat.size")
          }
          NavigationLink {
            ListsView()
              .navigationTitle("Lists")
              .navigationBarTitleDisplayMode(.inline)
          } label: {
            Label("Lists", systemImage: "list.bullet")
          }
          NavigationLink {
            TextStylesView()
              .navigationTitle("Text Styles")
              .navigationBarTitleDisplayMode(.inline)
          } label: {
            Label("Text Styles", systemImage: "textformat.abc")
          }
          NavigationLink {
            QuotesView()
              .navigationTitle("Quotes")
              .navigationBarTitleDisplayMode(.inline)
          } label: {
            Label("Quotes", systemImage: "text.quote")
          }
          NavigationLink {
            CodeView()
              .navigationTitle("Code")
              .navigationBarTitleDisplayMode(.inline)
          } label: {
            Label("Code", systemImage: "curlybraces")
          }
          NavigationLink {
            ImagesView()
              .navigationTitle("Images")
              .navigationBarTitleDisplayMode(.inline)
          } label: {
            Label("Images", systemImage: "photo")
          }
          NavigationLink {
            TablesView()
              .navigationTitle("Tables")
              .navigationBarTitleDisplayMode(.inline)
          } label: {
            Label("Tables", systemImage: "tablecells")
          }
          NavigationLink {
            LatexView()
              .navigationTitle("LaTeX")
              .navigationBarTitleDisplayMode(.inline)
            } label: {
              Label("LaTeX", systemImage: "textformat.size")
          }
        }
        Section("Extensibility") {
          NavigationLink {
            CodeSyntaxHighlightView()
              .navigationTitle("Syntax Highlighting")
              .navigationBarTitleDisplayMode(.inline)
          } label: {
            Label("Syntax Highlighting", systemImage: "circle.grid.cross.left.filled")
          }
          NavigationLink {
            ImageProvidersView()
              .navigationTitle("Image Providers")
              .navigationBarTitleDisplayMode(.inline)
          } label: {
            Label("Image Providers", systemImage: "powerplug")
          }
        }
        Section("Other") {
          NavigationLink {
            DingusView()
              .navigationTitle("Dingus")
              .navigationBarTitleDisplayMode(.inline)
          } label: {
            Label("Dingus", systemImage: "character.cursor.ibeam")
          }
          NavigationLink {
            RepositoryReadmeView()
              .navigationTitle("Repository README")
              .navigationBarTitleDisplayMode(.inline)
          } label: {
            Label("Repository README", systemImage: "doc.text")
          }
          NavigationLink {
            LazyLoadingView()
              .navigationTitle("Lazy Loading")
              .navigationBarTitleDisplayMode(.inline)
          } label: {
            Label("Lazy Loading", systemImage: "scroll")
          }
        }
      }
      .navigationTitle("MarkdownUI")
      }
      .sheet(isPresented: $showTextSelectionTest) {
        NavigationView {
            TextSelectionView()
                .navigationTitle("Text Selection Test")
                .navigationBarItems(trailing: Button("Done") {
                    showTextSelectionTest = false
            })
        }
      }
    }
  }
}

