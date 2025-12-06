import json

with open('aichatbot.swagger', 'r', encoding='utf-8') as f:
    data = json.load(f)

print("=" * 80)
print("CHATBOT AI API ENDPOINTS")
print("=" * 80)
print(f"Base Path: {data.get('basePath', '/')}")
print()

for path, methods in data['paths'].items():
    print(f"\n{'='*80}")
    print(f"Path: {path}")
    print(f"{'='*80}")
    
    for method, details in methods.items():
        if method == 'parameters':
            continue
            
        print(f"\n{method.upper()}")
        print(f"Summary: {details.get('summary', 'N/A')}")
        print(f"Description: {details.get('description', 'N/A')[:200]}...")
        
        if 'parameters' in details:
            print(f"Parameters:")
            for param in details['parameters']:
                required = "REQUIRED" if param.get('required') else "optional"
                print(f"  - {param['name']} ({param['in']}) [{required}]: {param.get('description', '')}")
        
        if 'responses' in details:
            print(f"Responses: {', '.join(details['responses'].keys())}")

print("\n" + "=" * 80)
print("DEFINITIONS")
print("=" * 80)
if 'definitions' in data:
    for name, schema in data['definitions'].items():
        print(f"\n{name}:")
        if 'properties' in schema:
            for prop, details in schema['properties'].items():
                required = "REQUIRED" if prop in schema.get('required', []) else "optional"
                prop_type = details.get('type', 'unknown')
                print(f"  - {prop} ({prop_type}) [{required}]")
