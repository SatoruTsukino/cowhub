# Luau Post-Edit Verification Rule

Every code generation or modification in this project must complete post-edit verification:

1. **Compile check:**
   Ensure zero syntax/compilation errors:
   ```bash
   luau-compile <file> > /dev/null
   ```
   Exit status must be 0.

2. **Register check:**
   Ensure max Luau registers < 200:
   ```bash
   LC_ALL=C luau-compile --text <file> | grep -o 'R[0-9]\{1,\}' | tr -d 'R' | sort -n | tail -1
   ```
   Output value must be strictly less than 200.

