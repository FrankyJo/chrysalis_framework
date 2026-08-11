# React refactoring patterns

- Extract business logic into custom hooks (`useXxx`), placed per the folder convention in the main `ch-execute` SKILL.md (a `<component-slug>` subfolder, not one flat shared directory). The hook returns state + handlers, the component stays presentational.
- Split huge JSX into smaller components along natural boundaries (repeated blocks, conditionally shown sections).
- If there's prop drilling through 3+ levels, consider Context, but don't introduce a new Context in the same step where you're already extracting logic into hooks — these are two different changes, do them sequentially.
- Don't change the component's public props/callbacks without a separate request.
- Watch useEffect/useMemo/useCallback dependencies when moving logic — a missing or extra dependency in the array is a typical source of regressions that unit tests may not catch.
- If the component is class-based, only convert it to functional + hooks if that's separately agreed on — don't mix it with structural splitting in one step.
- Memoization (React.memo/useMemo) — don't add it "just in case", only if profiling or an explicit problem justifies it.
