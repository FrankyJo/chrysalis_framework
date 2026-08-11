# Vue 3 refactoring patterns

- Extract business logic (not UI) into composables (`useXxx.js`/`.ts`), placed per the folder convention in the main `ch-execute` SKILL.md (a `<component-slug>` subfolder, not one flat shared directory). A composable returns reactive state + methods, the component stays thin — just rendering and calling the composable.
- If the component is on the Options API, only convert it to `<script setup>` Composition API in the same refactor if that was already agreed on; otherwise don't mix the two changes (API style + structure) in one step — it makes regressions harder to diagnose.
- Split a huge `<template>` into subcomponents along natural boundaries (repeated blocks, visually distinct sections, conditionally shown parts). Each subcomponent gets one responsibility.
- Vuex: don't change mutations/actions during a structural component refactor unless that's separately agreed on — extracting a `store.dispatch` call into a composable is fine, changing the action itself is a different task.
- Avoid mixins for new logic — replace them with composables.
- Don't change emits/props without a separate request — that's the component's public contract.
- Watch v-model and reactivity: when moving state into a composable, check that reactivity (ref/reactive) isn't lost on destructuring (use `toRefs` if needed).
