; extends

; Highlight Go template actions ({{ ... }}) inside YAML values.
;
; This covers templating in *values* -- `image: {{ .Values.tag }}` -- which
; the yaml parser still produces a node for. Standalone control lines
; (`{{- if .Values.enabled }}` on their own line) are not valid YAML, so the
; parser emits an ERROR node there and no injection is possible.

; Quoted and block scalars: "{{ .Chart.Version }}"
(
	[
		(single_quote_scalar)
		(double_quote_scalar)
		(block_scalar)
	] @injection.content
	(#lua-match? @injection.content "{{")
	(#set! injection.language "gotmpl")
	(#set! injection.include-children)
)

; Unquoted: `name: {{ .Values.name }}`. YAML reads the leading `{` as a flow
; mapping, so this arrives as a nested (flow_mapping) rather than a scalar.
; Anchor on the pair's value / sequence item to capture the OUTER node only --
; matching (flow_mapping) directly would also match the inner `{ ... }` and
; inject twice.
(
	block_mapping_pair
	value: (flow_node (flow_mapping)) @injection.content
	(#lua-match? @injection.content "^{{")
	(#set! injection.language "gotmpl")
	(#set! injection.include-children)
)

(
	block_sequence_item
	(flow_node (flow_mapping)) @injection.content
	(#lua-match? @injection.content "^{{")
	(#set! injection.language "gotmpl")
	(#set! injection.include-children)
)
