# Profile Avatar Prestige Design

**Date:** 2026-07-26  
**Status:** Approved for implementation planning

## Purpose

Make the profile avatar feel like a premium identity showcase while preserving
the value of earned tier progression. Free tier frames must be visually
distinct, calm, and recognisable at small sizes. Pro must feel like a refined
finish over the earned tier, not a replacement for it.

## Design Principles

1. The user's photo is always the focal point.
2. Tier is an achievement layer; its hue and crest stay visible when Pro is
   active.
3. Pro is a membership finish: antique-gold and deep-teal material, outer
   accents, ambient halo, and premium title.
4. Do not use repeated motion or partial halos as a default decoration.
5. Every tier needs a distinct combination of hue, frame construction, and
   crest at the 40dp top-bar size.

## Avatar Composition

The full profile avatar is layered in this order:

1. optional, subtle ambient aura behind the avatar;
2. tier frame and achievement crest;
3. clipped user photo or initials fallback;
4. optional Pro outer finish and teal membership crest;
5. optional equipped title outside the avatar.

The profile hero uses an 88--96dp avatar. The compact top-bar avatar remains
static and omits particles and decorative ambient layers. When no user photo
exists, use a clean initials/monogram fallback rather than a tier emoji.

## Tier-Tinted Profile Hero

The profile hero card uses the active tier palette so the card feels like an
extension of the avatar preview. It is not a solid coloured card:

- use the tier primary and secondary colours in a low-alpha background gradient
  (about 8--14%), a border (about 30--40%), and the XP progress fill;
- keep the reading surface, primary text, and photo area neutral for contrast;
- use the tier crest and avatar frame as the strong tier signals; the card tint
  is supporting atmosphere only;
- preserve the same structure in light theme using the existing light-safe tier
  ink colours rather than neon fills;
- for a Pro user, retain the tier-tinted card. Add only a thin antique-gold
  inlay and a deep-teal membership detail; never recolour the card gold.

For example, an Epic Pro user has a vermilion-tinted hero, a ruby achievement
frame, then restrained gold and teal Pro finishing. The user reads Epic first,
then Pro.

## Free Tier Frame System

All frames use a circular photo silhouette. The tier frame is a focused,
mostly static construction, not a stack of independent visual effects.

| Tier | Levels | Palette | Frame and crest | Outer halo |
| --- | ---: | --- | --- | --- |
| Warrior | 1--9 | Amethyst | Thin full ring | None |
| Elite | 10--19 | Sky azure | Double arc | Two short arcs |
| Master | 20--29 | Jade green | Full ring + diamond mark | None |
| Grandmaster | 30--39 | Royal sapphire | Faceted hex ring | None |
| Epic | 40--59 | Vermilion coral | Full ring + ruby seal | None |
| Legend | 60--79 | Lunar lavender | Moonlight ring + crescent crest | None |
| Mythic | 80--84 | Electric cyan | Star crest / constellation detail | None |
| Mythic Honor | 85--89 | Ultraviolet | Orbital crest | Two short arcs |
| Mythic Glory | 90--94 | Celestial magenta | Three spark marks | None |
| Mythic Immortal | 95+ | Obsidian opal | Pearl ring + eight-point crest | Full pearl ring |

Only Master uses green; only Epic uses red. Legend intentionally avoids grey,
Mythic intentionally avoids green, Glory intentionally avoids red-pink, and
Immortal uses a dark opal construction rather than a neutral grey. The tier
crest is part of the achievement layer and remains visible for Pro users.

Tier animation is limited to a low-key shimmer on direct interaction or the
full profile view for the highest tiers. It is disabled when reduced motion is
requested. No frame uses a continuous rotating ring by default.

## Pro Signature Finish

Pro uses antique gold and deep teal only; those colours are not assigned to a
progression tier. The treatment is intentionally light:

- two thin, broken antique-gold outer arcs, never a full gold ring;
- a restrained gold inlay / material edge;
- a small deep-teal membership crest;
- optional soft ambient halo behind the photo;
- a premium title chip such as `Al-Muhsin` near the profile identity.

The Pro finish is static in compact placements. In the profile hero it may use
one slow shimmer; it never places particles over the face.

### Epic + Pro example

For an Epic Pro user, the ruby inner ring and ruby seal still communicate
Epic. The Pro arcs sit outside that ring, while the teal crest and title
communicate membership. The visual reading order is: photo, achievement tier,
Pro finish, title. This composition is the template for every tier plus Pro.

## User States and Interactions

- **Free with a photo:** tier frame, optional earned cosmetic, no Pro finish.
- **Free without a photo:** initials/monogram fallback in the same tier frame.
- **Pro with a photo:** tier frame plus the Pro signature finish.
- **Pro without a photo:** initials/monogram plus the same Pro finish; no
  different decorative substitute.
- **Edit profile:** continues to change or remove the photo. It does not alter
  tier or Pro cosmetics.
- **Loker Skin:** remains the place to equip a frame, aura, or title. The hero
  updates immediately after an equip or unequip.

The existing quest explanation in the locker remains the guidance for earning
free cosmetics. This design adds no new entitlement or unlock mechanism.

## Accessibility and Performance

- Preserve a 44dp minimum touch target for edit and locker controls.
- Ensure tier and Pro state are not identified by colour alone; the frame and
  crest provide a second cue.
- Honour reduced-motion preferences and keep all decorative animation off the
  small avatar.
- Decode local photos at display resolution and avoid running animation
  controllers for inactive effects.

## Scope

This work revises the visual rules and presentation of the existing
`TierProfileAvatar` and profile hero. It does not add purchases, new cosmetic
catalog entries, a remote image service, or a new quest reward system.
