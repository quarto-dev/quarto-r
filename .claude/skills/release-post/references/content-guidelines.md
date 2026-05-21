# Content Guidelines for Release Posts

General best practices for release post content, regardless of blog platform. These guidelines are based primarily on Tidyverse blog conventions, which provide a principled approach to announcing package updates.

## Table of Contents

1. [Post Structure](#post-structure)
2. [Opening Style](#opening-style)
3. [Section Organization](#section-organization)
4. [Tone and Voice](#tone-and-voice)
5. [Code Examples](#code-examples)
6. [Acknowledgments](#acknowledgments)

## Post Structure

Standard structure for release posts:

```markdown
[Frontmatter - see formatting guides]

# Package Version

[Opening paragraph with package description]

[Installation instructions]

[Overview paragraph about the release]

## Major Feature 1
[Content...]

## Major Feature 2
[Content...]

## Minor improvements
[Bulleted list...]

## Acknowledgements
[Contributor list]
```

## Opening Style

### Opening Paragraph Pattern

Start with an announcement that establishes the package's core purpose:

> "We're [pleased/chuffed/stoked/thrilled/delighted/excited/...] to announce the release of [package] [version]. [Package] [core purpose description in one sentence]."

**Examples:**
- "We're chuffed to announce the release of testthat 3.3.0. testthat makes it easy to turn your existing informal tests into formal, automated tests"
- "We're pleased to announce the release of pkgdown 2.2.0. pkgdown is designed to make it quick and easy to build a beautiful and accessible website"
- "We're excited to announce the new Shiny extension for VS Code!"

**Vocabulary variations:**
- Choose an upbeat and random adjective with connotations of excitement.
- Be interesting and bold, but above all positive and fun.

### Installation Instructions

Follow the opening with installation instructions as a code block:

**R packages:**
```r
install.packages("packagename")
```

For multiple packages:
```r
install.packages(c("shiny", "bslib"))
```

**Python packages:**
```bash
pip install packagename
```

With extras:
```bash
pip install "packagename[extra]"
```

### Overview Paragraph

Brief overview of the release following installation:

- Link to full release notes when available
- Highlight focus areas: "This release focuses on [key themes]"
- Set expectations: "This is a [major/minor] release with [X main features]"
- Acknowledge breaking changes: "This release includes a number of new features... Some of these changes may require you to update your existing code"

## Section Organization

### Standard Section Hierarchy

Organize content in this order:

1. **Migration guide** (if breaking changes)
   - Put this first when there are breaking changes
   - Use clear before/after examples
   - Explain the rationale for changes

2. **Lifecycle changes** (if applicable but not breaking)
   - Soft deprecations
   - Deprecations
   - Defunct (removed) functions
   - Non-breaking behavioral changes

3. **Major new features** (primary content)
   - One section per major feature or theme
   - Use descriptive headings
   - Lead with what the feature does and why it matters
   - Include examples

4. **Minor improvements** or **Other new features**
   - Bulleted list of smaller enhancements
   - Brief explanations
   - Can group related items

5. **Acknowledgements** (always final)
   - Thank contributors
   - List all contributors with GitHub links

### Section Heading Style

- Use sentence case: "Lifecycle changes" not "Lifecycle Changes"
- Be descriptive: "Easier `in_parallel()`" not just "New feature"
- Include function names in backticks when relevant
- Make headings scannable and informative

### Content Organization Within Sections

**For migration guides:**
```markdown
## Migrating to vX.Y.Z

### Setting the app theme

Prior to vX.Y.Z, you could...

[Before example]

**With packagename vX.Y.Z,** you now need to...

[After example]

Read about [the feature](#feature) below to learn why this change was needed.
```

**For lifecycle changes:**
```markdown
## Lifecycle changes

* **Fully removed** after 5+ years of deprecation:
  * `function1()` - use `replacement1()` instead
  * `function2()` - use `replacement2()` instead

* **Newly deprecated** (soft-deprecation):
  * `function3()` is superseded by `function4()`
  * `function5()` is no longer recommended

* **Breaking changes**:
  * Brief description of the change and impact
```

**For feature sections:**
- Lead with a clear description of what the feature does
- Provide context on why it's useful or what problem it solves
- Include code examples showing usage
- Explain configuration options if relevant
- Link to relevant documentation

### Deep Dives on Features

Don't just list features from NEWS—research them and provide comprehensive explanations:

**Transform NEWS bullets into complete sections:**

1. **Research the feature**:
   - Read function documentation
   - Check related PRs and issues for context
   - Understand the motivation and use cases

2. **Add complete code examples**:
   - Show realistic usage, not just function signatures
   - Include comments explaining what's happening
   - Demonstrate the full workflow, not just isolated calls

3. **Explain the context**:
   - Why was this feature added?
   - What problem does it solve?
   - What are the practical use cases?
   - How does it fit into typical workflows?

4. **Show use cases and applications**:
   - Provide examples of when users would need this
   - Explain different configuration options
   - Show how features work together

**Example transformation:**

❌ **NEWS bullet approach:**
```markdown
## Bookmarking
- Added `chat_restore()` for bookmarking support (#82)
```

✅ **Deep dive approach:**
```markdown
### Bookmarking support

shinychat now supports Shiny's bookmarking feature for saving and restoring chat sessions.
The new `chat_restore()` function saves the chat client state and restores the message history:

[Complete code example showing actual usage]

By default, `chat_restore()` automatically updates the bookmark when users submit messages
and when the LLM completes its response. This means users can refresh the page or share a
URL and pick up right where they left off.

For apps with large chat histories, you can use `enableBookmarking = "server"` to store
state server-side without URL size limitations.
```

**Research sources:**
- Use `r-btw` tools to read R function documentation
- Read GitHub PRs/issues linked in NEWS
- Check package vignettes and articles
- Look at example apps in the repository

**For improvements:**
```markdown
## Minor improvements

* Brief description of improvement with function name in backticks
* Another improvement with relevant technical details
* Performance gains quantified when possible (e.g., "2x faster")
```

## Tone and Voice

### Writing Style

- **Conversational but professional**: "We're excited to announce" rather than "It is announced"
- **Inclusive**: Use "we" and "you" rather than passive voice
- **Enthusiastic but authentic**: Avoid over-the-top marketing language
- **Technical precision**: Use exact function names, parameter names, and technical terms
- **Focus on benefits**: Explain the "why" not just the "what"

### Avoiding Marketing Speak

Release posts should be friendly and instructional, not advertising. Watch for and remove:

**Superlatives and promotional adjectives:**
- ❌ "powerful set of features", "rich, interactive displays", "beautiful interface"
- ✅ "set of features", "interactive displays", "interface"

**Exaggerated benefit claims:**
- ❌ "handles all the complexity of persisting state"
- ✅ "saves the chat client state and restores the message history"

**Generic enthusiasm:**
- ❌ "opens up exciting possibilities for building transparent, user-friendly AI applications"
- ✅ Direct description of what the feature does

**Over-hyped capability statements:**
- ❌ "give you fine-grained control over every aspect"
- ✅ "lets you control the chat interface"

**Tone review checklist:**
- [ ] Remove words like "powerful", "robust", "seamless", "elegant", "revolutionary"
- [ ] Replace "makes it easy to" with direct descriptions of functionality
- [ ] Prefer descriptive statements focusing on what the function does
- [ ] Avoid overuse of phrases that sound like product marketing ("best-in-class", "production-ready")


### Common Phrases

- "We're [emotion] to announce..."
- "A big thank you to all the folks who helped make this release happen"
- "You can see a full list of changes in the release notes"
- "This makes it easier to..."
- "We've improved..."
- "This release focuses on..."
- "Prior to vX.Y.Z, you had to..."
- "With this release, you can now..."

### Technical Voice

- Use backticks for all code elements: `` `function()` ``, `` `argument` ``, `` `"value"` ``
- Link to relevant documentation when helpful
- Be specific about behavior: "returns `NULL`" not "returns nothing"
- Explain technical decisions when they impact users
- Acknowledge tradeoffs when present

## Code Examples

### Explain Concepts Before Code

For features that introduce new or unfamiliar concepts, explain the concept first before showing code:

**Pattern: Concept → How it works → Why it matters → Code**

1. **What is the feature/concept?** (1-2 sentences)
2. **How does it work?** (Especially non-obvious aspects)
3. **Why does it matter?** (Practical implications)
4. **Show the code** (With examples)

**Key principles:**
- Assume readers may not be familiar with the concept
- Explain non-obvious aspects clearly
- Connect concepts to practical outcomes
- Use plain language before technical language

### Inline Code

- Function names: `` `map_chr()` ``
- Arguments: `` `na.rm = TRUE` ``
- Values: `` `NULL` ``, `` `TRUE` ``, `` `"string"` ``
- File paths: `` `app.py` ``

### Code Block Principles

- Use realistic but simple examples
- Include expected output when relevant
- Show error messages for examples of better error handling
- Format multi-line function calls with proper indentation
- Add comments for clarity when needed: `# This does X`
- Keep examples focused on the feature being demonstrated

### Before/After Examples

When showing improvements, use clear before/after structure:

```markdown
Previously, you had to write:

[Code block showing old approach]

Now you can write:

[Code block showing new approach]
```

Or for migration guides:

```markdown
**Before:**

[Old code]

**After:**

[New code]
```

## Acknowledgments

### When to Include

- **Always include** for package releases with external contributors
- Optional for internal tooling announcements
- Include at the end as the final section

### Section Format

```markdown
## Acknowledgements

A big thank you to all [the folks/everyone] who [helped make this release happen/contributed to this release]:

[@username1](https://github.com/username1), [@username2](https://github.com/username2), ...
```

### Fetching Contributors

Use `usethis::use_tidy_thanks()` in R:

```r
# From last release to current
usethis::use_tidy_thanks("owner/repo")

# From specific tag/SHA
usethis::use_tidy_thanks("owner/repo", from = "v1.0.0")
```

This generates properly formatted markdown for the contributor list that can be included verbatim.

## Transforming NEWS to Blog Content

When converting NEWS.md entries to blog post format:

1. **Expand context**: Technical bullets become paragraphs explaining why changes matter
2. **Add examples**: Include code demonstrating new features or changes
3. **Group thematically**: Combine scattered NEWS items into coherent sections
4. **Use conversational tone**: Transform terse bullets into readable prose
5. **Link proactively**: Add links to relevant documentation and resources
6. **Focus on user impact**: Explain how changes affect typical usage
7. **Highlight breaking changes**: Make migration paths clear and prominent

## Release Notes Link

Always include a link to full release notes:

```markdown
You can see a full list of changes in the [release notes](url).
```

This allows readers to find exhaustive details while keeping the blog post focused and readable.
