import MarkdownUI
import SwiftUI

struct HeadingsView: View {
  private let content = """
    # Headings
    To create a heading, add one to size `#` symbols before your heading text.
    The number of `#` you use will determine the size of the heading:

    ```
    # The largest heading
    ## The second largest heading
    ###### The smallest heading
    ```

    # The largest heading
        
        some text
        
    ## The second largest heading
        
        some text
        
    ### The third largest heading
    
        some text
        
    #### The fourth largest heading
    
    some text
    
    ###### The smallest heading
    
    15–25% of total production costs (e.g., $150,000–$250,000 for a $1 million series).
    
    """

  var body: some View {
    DemoView {
      Markdown(self.content)
            .textSelection(.enabled)

      Section("Customization Example") {
        Markdown("# One Big Header")
              .textSelection(.enabled)

      }
      .markdownBlockStyle(\.heading1) { configuration in
        configuration.label
          .markdownMargin(top: .em(1), bottom: .em(1))
          .markdownTextStyle {
            FontFamily(.custom("Trebuchet MS"))
            FontWeight(.bold)
            FontSize(.em(2.5))
          }
      }
    }
  }
}
