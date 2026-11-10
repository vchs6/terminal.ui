"""Literal regular TOML fixtures; no TOML parser or expected-result derivation."""
from pathlib import Path

FIXTURES = {
    'A': ('A', 'red'), 'B': ('B', 'blue'), 'C': ('C', 'green'),
    'FileA': ('FileA', 'red'), 'FileB': ('FileB', 'blue'),
    'FileC': ('FileC', 'green'), 'FileD': ('FileD', 'cyan'),
    'OriginA': ('OriginA', 'red'), 'OriginB': ('OriginB', 'blue'),
    'OriginA2': ('OriginA2', 'green'), 'AppA': ('AppA', 'blue'),
    'AppB': ('AppB', 'green'), 'Observe': ('Observed', 'blue'),
    'Other': ('Other', 'yellow'), 'Old': ('Old', 'yellow'),
    'Fence': ('Fence', 'cyan'), 'Probe': ('Probe', None),
}

def literal(label):
    name, color = FIXTURES[label]
    text = f'schema_version=1\nname="{name}"\n'
    if color is not None:
        text += f'[text]\nforeground="{color}"\nbackground="default"\n'
    return text.encode()


def generate(root: Path):
    root.mkdir(parents=True, exist_ok=True)
    for name, label in {
        'gate-old.toml':'Old', 'gate-fence.toml':'Fence',
        'gate-other.toml':'Other', 'gate-inactive.toml':'Old',
        'gate-observe.toml':'Observe', 'gate-background.toml':'B',
        'gate-app-a.toml':'AppA', 'gate-app-b.toml':'AppB',
        'live.toml':'FileA', 'a/theme.toml':'OriginA', 'b/theme.toml':'OriginB',
        'gate-probe.toml':'Probe',
    }.items():
        target=root/name;target.parent.mkdir(parents=True,exist_ok=True)
        target.write_bytes(literal(label))
    for i in range(32):
        (root/f'gate-pending-{i}.toml').write_text(f'schema_version=1\nname="P{i}"\n[text]\nforeground="blue"\n')
    (root/'invalid.toml').write_text('schema_version=1\nname="Invalid"\n[text]\nbold=1\n')
    (root/'syntax.toml').write_text('schema_version=1\nname="Invalid"\n[text\n')
    (root/'invalid-utf8.toml').write_bytes(b'schema_version=1\nname="Bad\xff"\n')
    (root/'unknown-ref.toml').write_text('schema_version=1\nname="Invalid"\n[text]\nforeground={ref="missing"}\n')
    (root/'oversize.toml').write_bytes(literal('A')+b'#'+b'x'*1048576)
    (root/'deep.toml').write_text('schema_version=1\nname="Deep"\ntext.bold='+'['*10000+'0'+']'*10000)
    (root/'other').mkdir(exist_ok=True);(root/'other/marker').write_text('cwd-ok')
