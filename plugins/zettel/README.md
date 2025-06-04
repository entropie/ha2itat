# Zettel Plugin

Welcome to the Zettel Plugin, your digital Zettelkasten! This plugin
helps you create, manage, and interconnect a network of notes (called
"Sheets"), inspired by the Zettelkasten method. The core idea is to
build a web of knowledge through atomic notes that link to each other.

## How it Works

Each note in this system is a "Sheet." Sheets are designed to be
individual pieces of information, ideas, or thoughts that can be
linked together to form a larger body of knowledge.

### Key Features:

*   **Markdown Content:** Sheets are written (and always displayed) in Markdown, allowing for easy formatting and a focus on content.
*   **Media Uploads:** You can attach and embedd images 

## Interconnecting Your Sheets: The Power of Hashtags and References

The true power of the Zettelkasten method lies in the connections between notes. This plugin achieves this through a combination of hashtags and title-based referencing:

1.  **Hashtags for Topic Association and Linking (`#keyword`):**
    *   You create links or associate sheets with topics by embedding hashtags (e.g., `#project-management`, `#research-ideas`, `#important-concept`) directly within the Markdown content of your sheets.

2.  **How Sheets "Know" They Are Referenced (Backlinks):**
    *   A sheet discovers which other sheets reference it by looking for its **title**.
    *   If the exact title of Sheet A is used as a hashtag (e.g., `#SheeATitle`) within the content of Sheet B, then Sheet A will know that Sheet B references it.
    *   This allows you to see a list of "backlinks" for any given sheet, showing you where its ideas or information have been used or cited elsewhere in your Zettelkasten.

3.  **Viewing References:**
    *   The plugin provides a dedicated interface (usually found under a "References" section or by looking up a specific hashtag/title) where you can see all sheets associated with a particular hashtag or all sheets that reference a particular sheet title. This makes it easy to navigate the web of your notes.

### Example:

Imagine you have a **Sheet A** with the title "pomodoro".

You then create **Sheet B** and in its content, you write:
"I find that the `#pomodoro` Technique is very effective for `#productivity`."

*   Sheet B is now linked to the topics "The Pomodoro Technique" and "productivity" via hashtags.
*   Sheet A will now show that it is referenced by Sheet B because "pomodoro" (Sheet A's title) was used as a hashtag in Sheet B.

