# GSD Planning Outlines Rule

Every non-trivial implementation, feature addition, or refactor must strictly adhere to the GSD planning outlines:

1. **Protocol Adherence:**
   - Follow `SPEC → PLAN → EXECUTE → VERIFY → COMMIT`.
   - Never implement code without an active, finalized plan.

2. **Plan Outline Structure:**
   - Every plan must follow [`.gsd/templates/PLAN.md`](file:///Users/jsph/cowhub/.gsd/templates/PLAN.md).
   - Use standardized frontmatter: `phase`, `plan`, `wave`, `gap_closure`.
   - Structure every task inside XML semantic blocks:
     ```markdown
     <task type="auto|checkpoint">
       <name>Task name</name>
       <files>Exact file paths</files>
       <action>Steps, AVOID, USE guidelines</action>
       <verify>Executable command or empirical check</verify>
       <done>Measurable acceptance criteria</done>
     </task>
     ```

3. **Goal-Backward Planning:**
   - Work backward from verifiable outcomes.
   - Define required proof (compile check, register limits, command output) before executing changes.

