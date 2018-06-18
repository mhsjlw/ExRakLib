# ExRakLib

A RakNet server implementation in Elixir

- `lib/`, all source
- `test/`, all testing source
- `config/`, configuration (will be removed once converted into a library)

#### TODO
- [ ] Implement the reliability needed to power Terraria (mobile) and Minecraft: Bedrock Edition (all platforms)
- [ ] Implement a simple interface via an Elixir protocol for server handling
- [ ] Ensure no actors are leaked during creation and destruction
- [ ] Optimize for serialization speeds (IO lists, splits, compression, etc.)