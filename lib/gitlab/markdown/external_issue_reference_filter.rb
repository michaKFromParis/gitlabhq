module Gitlab
  module Markdown
    # HTML filter that replaces external issue tracker references with links.
    # References are ignored if the project doesn't use an external issue
    # tracker.
    class ExternalIssueReferenceFilter < ReferenceFilter
      # Public: Find `JIRA-123` issue references in text
      #
      #   ExternalIssueReferenceFilter.references_in(text) do |match, issue|
      #     "<a href=...>##{issue}</a>"
      #   end
      #
      # text - String text to search.
      #
      # Yields the String match and the String issue reference.
      #
      # Returns a String replaced with the return of the block.
      def self.references_in(text)
        text.gsub(ISSUE_PATTERN) do |match|
          yield match, $~[:issue]
        end
      end

      # Pattern used to extract `JIRA-123` issue references from text
      ISSUE_PATTERN = /(?<issue>([A-Z\-]+-)\d+)/

      def call
        return doc if project.default_issues_tracker?

        replace_text_nodes_matching(ISSUE_PATTERN) do |content|
          issue_link_filter(content)
        end
      end

      # Replace `JIRA-123` issue references in text with links to the referenced
      # issue's details page.
      #
      # text - String text to replace references in.
      #
      # Returns a String with `JIRA-123` references replaced with links. All
      # links have `gfm` and `gfm-issue` class names attached for styling.
      def issue_link_filter(text)
        project = context[:project]

        self.class.references_in(text) do |match, issue|
          url = url_for_issue(issue, project, only_path: context[:only_path])

          title = "Issue in #{project.external_issue_tracker.title}"
          klass = reference_class(:issue)

          %(<a href="#{url}"
               title="#{title}"
               class="#{klass}">#{issue}</a>)
        end
      end

      def url_for_issue(*args)
        IssuesHelper.url_for_issue(*args)
      end
    end
  end
end
