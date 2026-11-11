"""Append fixed T009 source spellings. Byte arithmetic only; no lexer/parser."""
from pathlib import Path

PREFIX = 'schema_version=1\nname="Case"\n'
ENCODINGS = ('bare', 'basic', 'literal', 'unicode', 'unicode-literal', 'mixed',
             'escape-short', 'escape-long', 'quote', 'backslash', 'punctuation')
CONTEXTS = ('ordinary', 'dotted', 'table', 'array-table', 'inline', 'array-inline')

def key_spelling(encoding: str, size: int) -> str:
    if encoding in ('bare', 'basic', 'literal'):
        payload = 'a' * size
    elif encoding in ('unicode', 'unicode-literal'):
        payload = '界' * 341 + 'a' * (size - 1023)  # 341*3 + 1/2
    elif encoding == 'mixed':
        payload = '界' * 170 + 'a' * (size - 510)  # 170*3 + 514/515
    elif encoding == 'escape-short':
        payload = r'\u0061' * 170 + 'a' * (size - 1020)  # 170*6 + 4/5
    elif encoding == 'escape-long':
        payload = r'\U00000061' * 102 + 'a' * (size - 1020)  # 102*10 + 4/5
    elif encoding == 'quote':
        payload = r'\"' * 512 + 'a' * (size - 1024)  # 512*2 + 0/1
    elif encoding == 'backslash':
        payload = '\\\\' * 512 + 'a' * (size - 1024)  # 512*2 + 0/1
    elif encoding == 'punctuation':
        payload = 'a.[{}]' * 170 + 'a' * (size - 1020)  # 170*6 + 4/5
    else:
        raise ValueError(encoding)
    assert len(payload.encode('utf-8')) == size, (encoding, size)
    if encoding == 'bare':
        return payload
    delimiter = "'" if encoding in ('literal', 'unicode-literal') else '"'
    return delimiter + payload + delimiter

def in_context(context: str, key: str) -> str:
    if context == 'ordinary': return PREFIX + key + '=true\n'
    if context == 'dotted': return PREFIX + 'text.' + key + '=true\n'
    if context == 'table': return PREFIX + '[' + key + ']\nbold=true\n'
    if context == 'array-table': return PREFIX + '[[' + key + ']]\nbold=true\n'
    if context == 'inline': return PREFIX + 'text={' + key + '=true}\n'
    if context == 'array-inline': return PREFIX + 'text=[{' + key + '=true}]\n'
    raise ValueError(context)

def generate_key_budget(directory: Path) -> None:
    directory.mkdir(parents=True, exist_ok=True)
    def put(name: str, text: str) -> None:
        data = text.encode('utf-8')
        assert len(data) < 4096  # Far below 1MiB; no other large resource axis.
        (directory / ('key-budget-' + name + '.toml')).write_bytes(data)
    for context in CONTEXTS:
        for encoding in ENCODINGS:
            for size in (1024, 1025):
                put(f'{context}-{encoding}-{size}', in_context(context, key_spelling(encoding, size)))
    for kind in ('styles', 'variables'):
        for spelling, key in (
                ('direct-103', 'a' * 103),
                ('escaped-103', '"' + r'\U00000061' * 103 + '"'),
                ('escaped-1024', '"' + r'\U00000061' * 102 + 'aaaa"'),
                ('escaped-1025', '"' + r'\U00000061' * 102 + 'aaaaa"')):
            if kind == 'styles':
                body = '[styles]\n' + key + '={text={bold=true}}\n'
            else:
                decoded = 'a' * (106 if spelling == 'escaped-1024' else 107 if spelling == 'escaped-1025' else 103)
                body = '[variables]\n' + key + '={type="bool",value=true}\n[text]\nbold={ref="' + decoded + '"}\n'
            put(f'{kind}-{spelling}', PREFIX + body)
    assert len((r'\U00000061' * 103).encode()) == 1030
    assert len(('a' * 103).encode()) == 103
    # String values/comments may exceed 1024 raw bytes without being key tokens.
    put('value-escaped-1030', 'schema_version=1\nname="' + r'\U00000061' * 103 + '"\n')
    put('value-literal-1025', 'schema_version=1\nname=\'' + 'a' * 1025 + "'\n")
    put('value-unicode-1026', 'schema_version=1\nname="' + '界' * 342 + '"\n')
    put('comment-1030', PREFIX + '#' + r'\U00000061' * 103 + '\n')
    put('comment-punctuation', PREFIX + '#' + 'a.[{}]' * 300 + '\ntext.bold=true\n')
    for spelling, body in (
            ('bare', 'text.bold=true\n'),
            ('literal', "'text'.'bold'=true\n"),
            ('escaped-short', r'"\u0074ext"."\u0062old"=true' + '\n'),
            ('escaped-long', r'"\U00000074ext"."\U00000062old"=true' + '\n'),
            ('inline', 'text={bold=true}\n'),
            ('table', '[text]\nbold=true\n')):
        put('equivalent-' + spelling, PREFIX + body)
