# Zettel Plugin

Welcome to the Zettel Plugin, your digital Zettelkasten! This plugin helps you create, manage, and interconnect a network of notes (called "Sheets"), inspired by the Zettelkasten method. The core idea is to build a web of knowledge through atomic notes that link to each other.

## How it Works

Each note in this system is a "Sheet." Sheets are designed to be individual pieces of information, ideas, or thoughts that can be linked together to form a larger body of knowledge.

### Key Features:

*   **Markdown Content:** Sheets are written in Markdown, allowing for easy formatting and a focus on content.
*   **Unique IDs:** Each sheet gets a unique ID, which forms part of its storage path.
*   **Metadata:** Information like creation date, update date, and title are stored alongside the content.
*   **Media Uploads:** You can attach images or other files to your sheets.

## Interconnecting Your Sheets: The Power of Hashtags and References

The true power of the Zettelkasten method lies in the connections between notes. This plugin achieves this through a combination of hashtags and title-based referencing:

1.  **Hashtags for Topic Association and Linking (`#keyword`):**
    *   You create links or associate sheets with topics by embedding hashtags (e.g., `#project-management`, `#research-ideas`, `#important-concept`) directly within the Markdown content of your sheets.
    *   The system parses these hashtags to understand the topics a sheet relates to.

2.  **How Sheets "Know" They Are Referenced (Backlinks):**
    *   A sheet discovers which other sheets reference it by looking for its **title**.
    *   If the exact title of Sheet A is used as a hashtag (e.g., `#Sheet A Title`) within the content of Sheet B, then Sheet A will know that Sheet B references it.
    *   This allows you to see a list of "backlinks" for any given sheet, showing you where its ideas or information have been used or cited elsewhere in your Zettelkasten.

3.  **Viewing References:**
    *   The plugin provides a dedicated interface (usually found under a "References" section or by looking up a specific hashtag/title) where you can see all sheets associated with a particular hashtag or all sheets that reference a particular sheet title. This makes it easy to navigate the web of your notes.

### Example:

Imagine you have a **Sheet A** with the title "The Pomodoro Technique".

You then create **Sheet B** and in its content, you write:
"I find that `#The Pomodoro Technique` is very effective for `#productivity`."

*   Sheet B is now linked to the topics "The Pomodoro Technique" and "productivity" via hashtags.
*   Sheet A will now show that it is referenced by Sheet B because "The Pomodoro Technique" (Sheet A's title) was used as a hashtag in Sheet B.

## Core Components

*   **`Sheet` (`lib/zettel/sheets.rb`):** Represents an individual note in the Zettelkasten. It manages the content, metadata, and its connections to other sheets.
*   **`References` (`lib/zettel/references.rb`):** This class is responsible for parsing hashtags from sheet content and determining the relationships (references and backlinks) between sheets.
*   **`Database` (`lib/zettel/database.rb`):** Handles the storage of sheets, which are typically saved as Markdown files for content and YAML files for metadata.
*   **`Slice` (within `slice/` directory):** Provides the web interface for creating, viewing, editing, and navigating your Zettelkasten, including the views for exploring references.

This system allows for a flexible and powerful way to build and navigate your personal knowledge base.
