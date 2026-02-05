# Others

# Index
- [Image manipulation](#image-manipulation)

****
## Image manipulation

```bash
# Strip all metadata from all images in current directory and subdirectories
exiftool -r -all= -overwrite_original .
```
### Or specify a directory
```bash
exiftool -r -all= -overwrite_original /path/to/your/images
```
### Creates .original backup files
```bash
exiftool -r -all= .
```

### Validate meta-data
```bash
# Find all images
find /path/to/images -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | sort

# Extract metadata from all images in a directory
exiftool -json -a -G1 -r /path/to/images

# Or save to file
exiftool -json -a -G1 -r /path/to/images > metadata_report.json
```

Quick scan for specific sensitive data:
```bash
# Search for PII/Copyright in metadata
exiftool -r -a -G1 /path/to/images | grep -i "serial\|gps\|artist\|copyright\|credit\|creator"
```
