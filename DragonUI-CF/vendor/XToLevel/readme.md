## XToLevel Addon Enhancement Summary

This document outlines a series of updates applied to the XToLevel addon. The goal of this initiative was to modernize the codebase, enhance performance, improve stability, and add new features, all while preserving the addon's original functionality and full compatibility with the World of Warcraft 3.3.5 client.

### Installation

1.  Download the latest version from the [Releases](https://github.com/mmobrain/XToLevel/releases) page.
2.  Extract the ZIP file.
3.  Copy the `XToLevel` folder into your `Interface\AddOns` directory in your World of Warcraft installation.
4.  Restart World of Warcraft.

#### 1. Integration with Project Ebonhold: Soul Ashes Support

*   **Objective:** To provide comprehensive tracking for the custom "Soul Ashes" currency system unique to the Project Ebonhold server environment.
*   **Observation:** Players on Project Ebonhold had no in-game method to track their Soul Ash acquisition rates or session totals within their existing interface.
*   **Enhancement:** Full support for Soul Ashes has been integrated:
    *   **Tracking:** A new module tracks total Soul Ashes earned per session.
    *   **Rate Calculation:** The addon now calculates "Soul Ashes per Hour" (SP/hr).
    *   **Intelligent Attribution:** Using event heuristics, the addon detects and categorizes Soul Ash gains as coming from either "Kills" or "Quests" based on recent quest completion events.
    *   **LDB & Tooltip:** New tags `{sph}` and `{sp_total}` are available for LDB displays, and detailed breakdowns are added to tooltips when hovering over relevant sections.
    *   **Optimization:** All Soul Ash logic is wrapped in smart polling that automatically disables itself on standard servers to ensure zero performance impact for non-Ebonhold players.
	
![image](https://i.imgur.com/OfbQ2kY.png)

#### 2. Core Stability Enhancement for Pet Module

*   **Objective:** To increase the reliability of the pet tracking features, particularly for hunter players.
*   **Observation:** Under certain conditions, such as when a pet was being summoned or swapped, the addon could occasionally encounter a Lua error related to accessing pet data before it was fully available from the game client.
*   **Enhancement:** The pet module (`objects/Pet.lua`) has been fortified with additional logic checks. These enhancements ensure that pet data is fully initialized and valid before being used, preventing potential errors and providing a smoother, more stable experience for users with combat pets.

#### 3. Performance Modernization for LDB Display

*   **Objective:** To optimize the LibDataBroker (LDB) component to reduce its impact on system performance during gameplay.
*   **Observation:** The process for generating the LDB text display was re-run on every experience gain. While functional, this presented an opportunity for optimization, especially in high-activity scenarios like dungeons or battlegrounds.
*   **Enhancement:** The LDB text generation logic was refactored to be more efficient. The text's structural pattern is now built and cached once, and only rebuilt when configuration settings are changed. Subsequent updates simply populate this cached template with fresh data. This change significantly reduces the addon's CPU usage during frequent XP updates, contributing to a smoother overall gameplay experience.

#### 4. New Feature Implementation: "Kill Range" Timer

*   **Objective:** To complete a planned feature and provide users with a more versatile "Time to Level" estimate.
*   **Observation:** The addon's design included a placeholder for a third timer mode based on recent kill speed, which now provides a more accurate estimate feature for players who enjoy grinding mobs.
*   **Enhancement:** The "Kill Range" timer mode has now been fully implemented. This new option calculates a "time to level" estimate based on the experience gained over the last several kills (the range is configurable in the Data panel). It offers a highly responsive, short-term performance metric that complements the existing "Session" and "Level" modes.

#### 5. Usability Upgrade: Custom LDB Pattern Helper

*   **Objective:** To make the powerful custom LDB pattern feature more accessible and user-friendly.
*   **Observation:** The custom pattern editor is an excellent tool for advanced users, but it lacked in-game documentation, making it difficult for players to discover and utilize its full potential.
*   **Enhancement:** A dedicated help section for "Custom LDB Patterns" has been added to the addon's interface options. This new panel provides comprehensive, easy-to-read documentation on all available tags, attributes, and styling options. This change empowers users to customize their LDB display with confidence, without needing to consult external guides.

#### 6. Code Quality Refinement: Configuration Panel Streamlining

*   **Objective:** To refactor the configuration panel's code for improved clarity, consistency, and ease of future maintenance.
*   **Observation:** The code for creating UI elements and handling data resets contained opportunities for consolidation.
*   **Enhancement:** The configuration code (`XToLevel.Config.lua`) has been streamlined by centralizing repetitive logic into helper functions. This refinement makes the code more efficient and robust, ensuring that future updates or additions to the options panel can be implemented more easily.

*This update outlines the changes implemented in version 3.3.5_15r.
*All recent changes and details should be included in changes.txt.
*~Skulltrail