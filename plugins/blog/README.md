# Blog

So, you want to blog? Join the club! This plugin provides all the digital ink and paper you'll need to share your thoughts with the world, or at least, with whoever stumbles upon your site.

## What it Does

The Blog plugin allows you to create, manage, and display blog posts. It's designed to be straightforward but flexible enough for your musings, rants, and groundbreaking manifestos.

Key features include:

*   **Markdown Support:** Write your posts in Markdown, because who has time for complicated editors?
*   **Image Handling:** Easily add images to your posts to make them less text-wall-y.
*   **Tags:** Organize your posts with tags, making it easier for readers (and you) to find specific topics.
*   **Drafts & Publication:** Write now, publish later. Or never. We don't judge.
*   **Internationalization (i18n):** Supports writing posts in multiple languages.

## Core Components

Under the hood, the plugin is powered by a few key components:

*   **`Post` Model (`lib/blog/post.rb`):** The heart of the plugin, defining what a blog post is and how it behaves. It handles content, metadata, slugs, and even knows about drafts.
*   **`Slice` (within `slice/` directory):** This is the web interface part of the plugin. It handles all the user-facing actions like displaying posts, creating new ones, editing existing ones, and managing their publication status. It defines routes like `/blog`, `/blog/create`, `/blog/show/:slug`, etc.
*   **Adapters & Configuration:** The plugin is designed to integrate with the main application, with various configuration options for things like templates and data storage.

So go ahead, start blogging! The internet awaits your wisdom.
