# Angular refactoring patterns

- Extract business logic (API calls, computations, validation) into services (`@Injectable`). The component stays "thin" — it coordinates rather than implements.
- If there's repeated template logic, extract standalone components or directives along natural boundaries.
- Only consider moving to Signals instead of RxJS patterns if that's separately agreed on — don't mix a reactive-model change with a structural refactor in one step.
- Follow smart/dumb (container/presentational) component separation: the container knows about services and state, the presentational component gets everything via @Input/@Output.
- Don't change the @Input/@Output public contract without a separate request.
- Watch unsubscribe/takeUntil when moving subscriptions into a service — a subscription leak is a typical silent regression.
- OnPush change detection: if the component already uses it, verify that after the refactor state mutations still go through immutably (don't mutate objects directly).
