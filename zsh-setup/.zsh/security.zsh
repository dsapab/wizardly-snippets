# ============================================================================
#  ~/.zsh/security.zsh — security-related shell hardening
# ----------------------------------------------------------------------------
#  Small, portable security tweaks kept in one place so they are easy to review.
# ============================================================================

# Mitigate the Log4Shell (CVE-2021-44228) JNDI lookup vector for JVM tools by
# disabling message-format lookups in any JVM launched from this shell.
export JAVA_TOOLS_OPTIONS="-Dlog4j2.formatMsgNoLookups=true"
