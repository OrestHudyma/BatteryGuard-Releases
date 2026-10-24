"""Static package inspection only. Never import/execute provider code."""
import hashlib, json, re, sys, zipfile
from pathlib import Path

def validate(path):
    path = Path(path)
    assert path.stat().st_size <= 20 * 1024 * 1024, 'Oversized archive'
    with zipfile.ZipFile(path) as z:
        infos = z.infolist()
        assert len(infos) == 3 and {x.filename for x in infos} == {'manifest.json', 'provider.dll', 'README.md'}, 'Unexpected/duplicate entries'
        assert all(0 < x.file_size <= (16 * 1024 * 1024 if x.filename == 'provider.dll' else 256 * 1024) for x in infos), 'Oversized entry'
        def unique(pairs):
            result = {}
            for k, v in pairs:
                assert k not in result, 'Duplicate JSON key'
                result[k] = v
            return result
        m = json.loads(z.read('manifest.json').decode('utf-8-sig'), object_pairs_hook=unique)
        assert set(m) == {'SchemaVersion','ApiVersion','Id','Version','Name','Author','EntryType','Control','Minimum','Maximum','Step','Notes','Profiles'}, 'Manifest fields'
        assert m['SchemaVersion'] == m['ApiVersion'] == 1
        assert re.fullmatch(r'[a-z0-9][a-z0-9-]{2,63}', m['Id']) and m['Id'] != 'hp-wmi-battery-control'
        assert m['Id'] not in {'con','prn','aux','nul'} and not re.fullmatch(r'(com|lpt)[0-9]',m['Id'])
        assert re.fullmatch(r'\d+\.\d+\.\d+', m['Version'])
        assert re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]*(\.[A-Za-z_][A-Za-z0-9_]*)+',m['EntryType'])
        assert m['Control'] in {'MonitorOnly','SoftwarePause','UpperLimit','DualLimits'}
        assert all(type(m[x]) is int for x in ('Minimum','Maximum','Step'))
        assert 1 <= m['Minimum'] < m['Maximum'] <= 100 and 1 <= m['Step'] <= 100
        if m['Control'] in {'SoftwarePause','DualLimits'}:
            assert m['Minimum'] + m['Step'] <= m['Maximum'], 'Two distinct thresholds required'
        assert all(isinstance(m[x],str) and 0 < len(m[x]) <= 120 for x in ('Name','Author'))
        assert isinstance(m['Notes'],str) and len(m['Notes']) <= 2000
        assert isinstance(m['Profiles'],list) and 1 <= len(m['Profiles']) <= 100
        ids = set()
        for p in m['Profiles']:
            assert set(p) == {'SchemaVersion','Id','DisplayName','Manufacturer','Model','Board','Bios','Provider','ProviderVersion','Notes'}
            assert p['SchemaVersion'] == p['ProviderVersion'] == 1 and p['Provider'] == m['Id']
            assert re.fullmatch(r'[a-z0-9][a-z0-9-]{2,63}',p['Id']) and p['Id'] not in ids
            ids.add(p['Id'])
            for field in ('DisplayName','Manufacturer','Model','Board','Bios'):
                value=p[field]
                assert isinstance(value,str) and value.strip()==value and 1 <= len(value) <= 160
                assert not any(ord(c)<32 or c in '*?' for c in value)
            assert isinstance(p['Notes'],str) and len(p['Notes']) <= 2000
        name=f"BatteryGuard-Plugin-{m['Id']}-{m['Version']}.zip"
        assert path.name == name, 'Filename does not match manifest'
        return dict(Id=m['Id'],Version=m['Version'],AssetName=name,Sha256=hashlib.sha256(path.read_bytes()).hexdigest())

if __name__ == '__main__':
    print(json.dumps(validate(sys.argv[1]), separators=(',',':')))
