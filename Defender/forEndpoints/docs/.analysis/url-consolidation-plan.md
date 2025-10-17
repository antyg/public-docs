# URL Reference Consolidation Plan

## Objective

Consolidate duplicate URL references created during footnote-to-reference transformation while preserving all inline citations and maintaining link functionality.

## Root Cause Analysis

Previous transformation converted `[^N]` footnote syntax to `[N]` reference syntax without semantic URL deduplication, resulting in multiple reference numbers pointing to identical URLs.

## Validation Findings

- **URLs unchanged**: Original and current URLs are identical (verified via git diff)
- **Only notation changed**: `[^N]` → `[N]` mechanical conversion
- **No content loss**: All original URLs preserved

## Files Requiring Consolidation

### High Priority

1. **05-Advanced-Hunting-KQL.md**
   - Original footnotes: 40
   - Unique URLs: 15
   - Duplicates: 25 (62.5% duplication rate)
   - **CRITICAL**: Highest duplication rate

2. **07-WMI-CIM-Validation.md**
   - Original footnotes: 18
   - Unique URLs: 11
   - Duplicates: 7 (38.9% duplication rate)

### Medium Priority

3. **INDEX.md**
   - Duplicates: 3 references to `troubleshoot-onboarding`

4. **02-Graph-API-Validation.md**
   - Duplicates: 2 references to `get-machines` API

5. **03-Security-Console-Manual.md**
   - Duplicates: 2 references to `machines-view-overview`

## Consolidation Strategy

### Phase 1: Analysis (Per File)

1. Extract all inline citations with pattern `[text][N]`
2. Map each `[N]` to its URL from References section
3. Group citations by URL
4. Select primary reference number (lowest `N` for each unique URL)

### Phase 2: Mapping Creation

For each file, create mapping:

```yaml
URL: primary_ref_number
  duplicate_refs: [list of duplicate numbers]
  inline_occurrences: count
```

### Phase 3: Inline Citation Updates

1. Find all inline citations using duplicate reference numbers
2. Replace with primary reference number for that URL
3. Preserve surrounding text and markdown formatting

### Phase 4: References Section Updates

1. Remove duplicate reference definitions `[N]: URL`
2. Update visible reference list to show only unique references
3. Renumber references sequentially if needed

### Phase 5: Validation

1. Verify all inline `[N]` have corresponding `[N]: URL` definition
2. Check no broken links (all URLs still accessible)
3. Confirm visible reference list matches invisible definitions
4. Validate markdown renders correctly

## Implementation Order

### 07-WMI-CIM-Validation.md (Smaller file - test case)

```
Known duplicates:
- [5] and [6] → https://learn.microsoft.com/.../msft-mpcomputerstatus
- [13] and [14] → https://learn.microsoft.com/.../tamper-protection

Action: Consolidate to [5] and [13], update all inline citations
```

### 05-Advanced-Hunting-KQL.md (Largest file - careful approach)

```
Multiple URL groups with 3-11 duplicate references each
Requires comprehensive mapping before any changes
```

### INDEX.md, 02-Graph-API-Validation.md, 03-Security-Console-Manual.md

```
Simple cases with 1-2 duplicate groups each
Quick consolidation after testing approach on 07-WMI-CIM
```

## Risk Mitigation

### Pre-Consolidation Backup

- Create git commit before any changes
- Document original state for each file

### Atomic Changes

- Complete one file fully before starting next
- Validate each file after consolidation

### Rollback Plan

- If issues detected: `git checkout <file>` to revert
- If systematic issues: revert entire commit

## Success Criteria

✅ All duplicate URLs consolidated to single reference number
✅ All inline citations point to valid reference definitions
✅ Visible reference lists show only unique URLs
✅ Markdown linter passes with no warnings
✅ All links render and work correctly
✅ No content loss or broken citations

## Estimated Impact

| File                          | Before      | After        | Reduction  |
| ----------------------------- | ----------- | ------------ | ---------- |
| 05-Advanced-Hunting-KQL.md    | 40 refs     | ~15 refs     | -62.5%     |
| 07-WMI-CIM-Validation.md      | 18 refs     | ~11 refs     | -38.9%     |
| INDEX.md                      | 8 refs      | ~6 refs      | -25%       |
| 02-Graph-API-Validation.md    | 8 refs      | ~7 refs      | -12.5%     |
| 03-Security-Console-Manual.md | 10 refs     | ~9 refs      | -10%       |
| **Total**                     | **84 refs** | **~48 refs** | **-42.9%** |

## Next Steps

1. Execute Task 1: Analyze 07-WMI-CIM-Validation.md
2. Create consolidation mapping
3. Test consolidation on single file
4. Validate and refine approach
5. Scale to remaining files
