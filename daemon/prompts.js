'use strict';

function enrichmentPrompt(post) {
  const repoLine = post.linked_repo ? `\nLinked repository: ${post.linked_repo}` : '';
  return `You are analyzing a startup/product idea submitted to an idea-sharing platform. Produce a structured analysis in two sections.

Idea title: ${post.title}
Category: ${post.category || 'tech'}${repoLine}

Idea description:
${post.content}

Respond in this exact format (no extra text before or after):

SPEC:
[Write a detailed product specification: target users, core problem, key features, success metrics, potential risks. 3-5 paragraphs.]

PLAN:
[Write a concrete implementation plan: tech stack recommendation, MVP scope, development phases, estimated complexity. Use numbered steps.]`;
}

function ideaBasePrompt(topic, description) {
  const descLine = description ? `\nContext: ${description}` : '';
  return `Generate 8 distinct, concrete startup/product ideas related to the following topic.${descLine}

Topic: ${topic}

Each idea must be something a small team could actually build. Be specific and practical, not generic.

Respond with a JSON array only (no markdown, no extra text):
[
  {
    "title": "Short descriptive title (max 80 chars)",
    "content": "2-3 sentence description of the idea, the problem it solves, and why it matters.",
    "category": "tech|business|health|productivity|finance|sustainability"
  }
]`;
}

function codegenPrompt(post, repoContext) {
  return `You are implementing a product idea as code in an existing repository.

Idea: ${post.title}
Description: ${post.content}
Repository: ${post.linked_repo}

${repoContext ? `Repository context:\n${repoContext}\n` : ''}

Write the implementation. Be practical and focused on MVP. Output runnable code with file paths as comments above each block (e.g., // src/feature.js).`;
}

module.exports = { enrichmentPrompt, ideaBasePrompt, codegenPrompt };
