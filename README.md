# SENTINEL AI V0.1

A Godot 4.3 Android prototype for a future offline cybersecurity AI agent.

## Implemented
- Procedural 3D laboratory, simple avatar and touch camera rotation.
- Local chat interface with **clearly limited rule-based responses** (NOT an LLM).
- Local persistent JSON conversation and task list (`user://sentinel_memory.json`).
- Research task selection (task scheduling stub, NOT automated research).
- GitHub Actions Android debug APK build configuration.

## Not implemented yet
- llama.cpp / Qwen local inference.
- Speech recognition and speech synthesis (voice button is a UI placeholder).
- Kotlin foreground service, WorkManager, and background execution.
- Device security monitoring and real autonomous research.

## Run on Android
1. Create a private GitHub repository.
2. Upload all project files, preserving `.github/workflows/android-apk.yml`.
3. Go to Actions > Build SENTINEL AI Android APK > Run workflow.
4. After a successful build, open the workflow run > Artifacts and download `SENTINEL_AI_Android_Debug`.
5. Extract the ZIP and install the APK on the Samsung S23 Ultra. Enable installation from the file manager if prompted.

The workflow is supplied but has NOT been executed or validated in GitHub Actions. If it fails, inspect the job logs. Android export SDK and keystore paths may need to be configured explicitly for your environment.

## Next implementation milestones
1. Kotlin Android plugin and Android speech TTS/STT.
2. Native llama.cpp arm64 Android inference and GGUF model management.
3. SQLite persistent memory with document indexing.
4. WorkManager scheduler, optional foreground service, safe task boundaries.
5. Android security diagnostics using documented permissions.

## Security
No root, no privileged system access, no external network actions in V0.1. Never put AI API keys inside the APK.
