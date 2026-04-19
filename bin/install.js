#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const os = require('os');

const args = process.argv.slice(2);
const isGlobal = args.includes('--global') || args.includes('-g');
const showHelp = args.includes('--help') || args.includes('-h');

if (showHelp) {
  console.log(`
flywheel-claude-code — install flywheel skills for Claude Code

Usage:
  npx flywheel-claude-code           Install to current project (.claude/skills/)
  npx flywheel-claude-code --global  Install globally (~/.claude/skills/)

Options:
  --global, -g   Install to ~/.claude/skills/ for all projects
  --help, -h     Show this help
`);
  process.exit(0);
}

const skillsSource = path.join(__dirname, '..', 'claude-code', 'skills');
const targetBase = isGlobal
  ? path.join(os.homedir(), '.claude')
  : path.join(process.cwd(), '.claude');
const skillsTarget = path.join(targetBase, 'skills');

console.log(`\nInstalling flywheel skills ${isGlobal ? 'globally (~/.claude/skills/)' : 'to project (.claude/skills/)'}...\n`);

fs.mkdirSync(skillsTarget, { recursive: true });

const skills = fs.readdirSync(skillsSource).filter(f => f.endsWith('.md'));
for (const skill of skills) {
  fs.copyFileSync(path.join(skillsSource, skill), path.join(skillsTarget, skill));
  console.log(`  ✓ ${skill}`);
}

console.log(`\nInstalled to ${skillsTarget}`);
console.log(`\nAvailable in Claude Code:`);
console.log(`  /flywheel-brainstorm  Design phase — define Theory of Success`);
console.log(`  /flywheel-plan        Planning — Theory of Success per task, no TDD`);
console.log(`  /flywheel-execute     Execution — implement → prove → verify loop`);
console.log(`  /flywheel-cleanup     Acceptance gate → cleanup → commit`);
console.log(`\nStart with /flywheel-brainstorm\n`);
