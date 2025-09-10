# Copilot Instructions for SourceMod Teleport Plugin

## Repository Overview

This repository contains a **SourceMod plugin** written in **SourcePawn** that provides teleportation commands for Source engine game servers. The plugin allows administrators to teleport players using various commands, enhancing server management capabilities.

### Core Functionality
The Teleport plugin provides four main admin commands:
- `sm_bring <target>` - Brings a player to the admin's current position
- `sm_goto <target|@aim>` - Teleports admin to a player or to their aimpoint
- `sm_send <target> <destination|@aim>` - Sends one player to another player or aimpoint
- `sm_tpaim <target>` - Teleports a player to the admin's aimpoint

## Technical Environment

### Core Technologies
- **Language**: SourcePawn (SourceMod scripting language)
- **Platform**: SourceMod 1.11.0+ (latest stable recommended)
- **Build System**: SourceKnight (modern SourceMod build tool)
- **CI/CD**: GitHub Actions with automated building and releases

### Dependencies
- **SourceMod**: Version 1.11.0-git6917 or newer
- **MultiColors**: For colored chat message support (included in build)
- **SDKTools**: For player manipulation functions (part of SourceMod)

### Development Environment Setup
```bash
# Build the plugin using SourceKnight
# SourceKnight will automatically download dependencies
cd /path/to/repository
sourceknight build

# Or use GitHub Actions workflow locally if available
```

## File Structure

```
sm-plugin-Teleport/
├── .github/
│   ├── workflows/ci.yml          # GitHub Actions CI/CD pipeline
│   └── copilot-instructions.md   # This file
├── addons/sourcemod/scripting/
│   └── Teleport.sp              # Main plugin source code
├── sourceknight.yaml            # Build configuration
└── .gitignore                   # Git ignore rules
```

### Key Files
- **`Teleport.sp`**: Main plugin implementation with all teleportation logic
- **`sourceknight.yaml`**: Build configuration defining dependencies and targets
- **`.github/workflows/ci.yml`**: Automated build and release pipeline

## SourcePawn Coding Standards

### Syntax Requirements
```sourcepawn
#pragma semicolon 1              // Mandatory semicolon usage
#pragma newdecls required        // Enforce new declaration syntax
```

### Naming Conventions
- **Functions**: PascalCase (`Command_Bring`, `TracePlayerAngles`)
- **Variables**: camelCase (`iTargetCount`, `vecClientPos`)
- **Global Variables**: Prefix with `g_` (`g_hDatabase`)
- **Constants**: UPPER_CASE (`MAXPLAYERS`, `MAX_TARGET_LENGTH`)

### Code Style
- **Indentation**: Use tabs (4 spaces equivalent)
- **Braces**: K&R style (opening brace on same line)
- **Comments**: Only where necessary for complex logic
- **Line Endings**: Remove trailing whitespace

### Memory Management
```sourcepawn
// Always clean up handles
Handle hTraceRay = TR_TraceRayFilterEx(...);
if (TR_DidHit(hTraceRay)) {
    // Use the handle
}
delete hTraceRay;  // Always delete, no null check needed

// For StringMaps/ArrayLists
delete myStringMap;          // Don't use .Clear() - creates memory leaks
myStringMap = new StringMap(); // Create new instance
```

## Plugin Architecture

### Core Functions
1. **OnPluginStart()**: Registers admin commands and loads translations
2. **Command Handlers**: Process user input and execute teleportation
3. **TracePlayerAngles()**: Utility function for aimpoint calculations
4. **TraceEntityFilter_FilterPlayers()**: Filter function for ray tracing

### Command Processing Pattern
```sourcepawn
public Action Command_Example(int client, int argc) {
    // 1. Validate client (not server console where required)
    if (!client) {
        ReplyToCommand(client, "[SM] Cannot use command from server console.");
        return Plugin_Handled;
    }
    
    // 2. Check argument count
    if (argc < 1) {
        CPrintToChat(client, "{green}[SM] {default}Usage: command <args>");
        return Plugin_Handled;
    }
    
    // 3. Process target string
    char sArgs[64];
    GetCmdArg(1, sArgs, sizeof(sArgs));
    
    // 4. Handle special cases (@aim, etc.)
    // 5. Execute teleportation
    // 6. Log action and show activity
    
    return Plugin_Handled;
}
```

## Build Process

### Using SourceKnight
```bash
# Install SourceKnight (if not available)
pip install sourceknight

# Build the plugin
sourceknight build

# Output will be in .sourceknight/package/
```

### Build Configuration (sourceknight.yaml)
- Automatically downloads SourceMod and dependencies
- Includes MultiColors for colored chat messages
- Outputs compiled .smx file to plugins directory
- Supports version 1.11.0-git6917 or newer

### GitHub Actions Workflow
- **Triggers**: Push, Pull Request, Manual dispatch
- **Process**: Build → Package → Release (for tags/main branch)
- **Artifacts**: Compiled plugin files in tar.gz format

## Testing Approach

### Manual Testing
1. **Setup Test Server**: Install SourceMod on a Source engine game server
2. **Install Plugin**: Copy compiled .smx to `addons/sourcemod/plugins/`
3. **Test Commands**: Use each command with various parameters:
   ```
   sm_bring player1
   sm_goto @aim
   sm_send player1 player2
   sm_tpaim player1
   ```

### Testing Scenarios
- **Valid targets**: Single player, multiple players (@all, @ct, @t)
- **Invalid targets**: Non-existent players, dead players
- **Special targets**: @aim functionality, trace ray validation
- **Permission checks**: Admin-only access validation
- **Edge cases**: Server console usage, invalid arguments

### Common Issues to Test
- Ray tracing failure (aimpoint in void)
- Target immunity bypassing
- Multiple target handling
- Logging and activity messages
- Translation loading

## Development Workflow

### Making Changes
1. **Edit Source**: Modify `Teleport.sp` using SourcePawn syntax
2. **Build Locally**: Use `sourceknight build` to compile
3. **Test**: Deploy to test server and verify functionality
4. **Commit**: Follow conventional commit messages
5. **CI/CD**: GitHub Actions will build and create releases

### Adding New Commands
```sourcepawn
// In OnPluginStart()
RegAdminCmd("sm_newcommand", Command_NewCommand, ADMFLAG_GENERIC, "Description");

// Command handler
public Action Command_NewCommand(int client, int argc) {
    // Follow established patterns from existing commands
    // Include proper validation, logging, and activity messages
    return Plugin_Handled;
}
```

### Debugging Tips
- Use `PrintToServer()` or `LogMessage()` for debugging output
- Test with various game clients and scenarios
- Check SourceMod logs for errors: `addons/sourcemod/logs/`
- Use SourceMod's error reporting for API issues

## Plugin-Specific Knowledge

### Teleportation Mechanics
- Uses `TeleportEntity(client, origin, angles, velocity)`
- Angles and velocity can be `NULL_VECTOR` to preserve current values
- Position arrays are 3D float vectors `[x, y, z]`

### Target Processing
- `ProcessTargetString()` handles player selection patterns
- Supports single players, groups (@all, @ct, @t), and special targets
- Returns target count and fills arrays with client indices
- Built-in immunity and filter checking

### Ray Tracing (@aim functionality)
- `TR_TraceRayFilterEx()` creates ray from player's eye position
- Filter function excludes players from trace hits
- Always clean up trace handles with `delete`
- Check `TR_DidHit()` before getting end position

### Activity Logging
- Use `CShowActivity2()` for colored admin activity messages
- Use `LogAction()` for permanent server logs
- Include both source admin and target information
- Handle multiple target scenarios appropriately

## Common Maintenance Tasks

### Version Updates
- Update version in plugin info structure
- Update dependencies in `sourceknight.yaml` if needed
- Test with latest SourceMod builds
- Update minimum version requirements in documentation

### Security Considerations
- Admin commands require `ADMFLAG_GENERIC` by default
- Target immunity prevents abuse of lower-privilege admins
- Input validation prevents potential exploits
- Server console restrictions where appropriate

### Performance Notes
- Ray tracing is computationally expensive - use sparingly
- Multiple target operations scale with player count
- No persistent data storage - minimal memory footprint
- Event-driven design minimizes server impact

## Troubleshooting

### Build Issues
- Ensure SourceKnight is installed and updated
- Check dependency availability (SourceMod version)
- Verify MultiColors include is accessible
- Review build logs for specific error messages

### Runtime Issues
- Check SourceMod version compatibility (1.11+)
- Verify admin permissions for command users
- Test ray tracing functionality on different maps
- Review server logs for detailed error information

### Common Error Patterns
- Handle overflow: Use proper buffer sizes for strings
- Memory leaks: Always delete handles and objects
- Invalid clients: Check `IsClientValid()` and `IsClientInGame()`
- Map compatibility: Some maps may have tracing issues

## Best Practices for Future Development

### Code Quality
- Follow established naming conventions consistently
- Add comments only for complex algorithms or non-obvious logic
- Use meaningful variable names that describe their purpose
- Keep functions focused on single responsibilities

### Error Handling
- Always validate user input and command arguments
- Provide helpful error messages to administrators
- Log important actions for server administration
- Handle edge cases gracefully (invalid traces, dead players, etc.)

### Maintainability
- Keep command handlers similar in structure
- Reuse utility functions for common operations
- Document any complex teleportation logic
- Test thoroughly with various player scenarios

This plugin serves as an excellent example of well-structured SourceMod development, following community best practices while providing essential server administration functionality.