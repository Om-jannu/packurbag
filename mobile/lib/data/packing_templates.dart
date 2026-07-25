/// Quick-apply packing list templates, keyed by trip type. Each entry is
/// (item text, category).
const packingTemplates = <String, List<(String, String)>>{
  'Beach': [
    ('Swimsuit', 'Clothing'),
    ('Sunscreen', 'Toiletries'),
    ('Sunglasses', 'Accessories'),
    ('Flip-flops', 'Clothing'),
    ('Beach towel', 'Accessories'),
    ('Hat', 'Clothing'),
  ],
  'Hiking': [
    ('Hiking boots', 'Clothing'),
    ('Backpack', 'Gear'),
    ('Water bottle', 'Gear'),
    ('First aid kit', 'Gear'),
    ('Trail snacks', 'Other'),
    ('Rain jacket', 'Clothing'),
  ],
  'Business': [
    ('Formal attire', 'Clothing'),
    ('Laptop', 'Electronics'),
    ('Chargers', 'Electronics'),
    ('Business cards', 'Other'),
    ('Dress shoes', 'Clothing'),
  ],
  'General': [
    ('Passport', 'Documents'),
    ('Phone charger', 'Electronics'),
    ('Toiletries', 'Toiletries'),
    ('Medications', 'Other'),
    ('Travel adapter', 'Electronics'),
    ('Extra clothes', 'Clothing'),
  ],
};
