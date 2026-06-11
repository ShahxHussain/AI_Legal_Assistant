"""End-to-end test: Urdu-script legal question -> translate -> retrieve -> generate."""

import os
import sys
import time

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from rag.embedder import Embedder
from rag.generator import Generator
from rag.query_intent import is_conversational_query, is_legal_query
from rag.retriever import Retriever

QUESTION = (
    "میں لاہور میں رہتا ہوں۔ گزشتہ ہفتے رات کے وقت کسی شخص نے میری دکان میں گھس کر "
    "نقد رقم اور ایک لیپ ٹاپ چوری کر لیا۔ اگلی صبح میں پولیس اسٹیشن گیا، لیکن وہاں "
    "موجود افسر نے کہا کہ وہ ابھی ایف آئی آر درج نہیں کر سکتے کیونکہ پہلے انہیں "
    "تحقیقات کرنی ہوں گی۔ اگر چوری ہونے والے سامان کی مالیت تقریباً 150,000 پاکستانی "
    "روپے ہے، تو پاکستان پینل کوڈ (PPC) کی کون سی دفعہ لاگو ہو سکتی ہے؟ نیز، ضابطہ "
    "فوجداری (CrPC) کے تحت اس جرم کی رپورٹ درج کروانے کا طریقہ کار کیا ہے؟"
)

print("is_legal_query:", is_legal_query(QUESTION))
print("is_conversational_query:", is_conversational_query(QUESTION))
print("short urdu legal q conversational?:", is_conversational_query("چوری کی سزا کیا ہے؟"))

gen = Generator()

t0 = time.time()
translated = gen.translate_query(QUESTION)
print(f"\n--- translated query ({time.time()-t0:.1f}s) ---")
print(translated)

embedder = Embedder()
retriever = Retriever(embedder)
retriever.load()

t0 = time.time()
chunks = retriever.retrieve(translated)
print(f"\n--- retrieved ({time.time()-t0:.1f}s) ---")
for c in chunks:
    print(f"  {c.score:.3f} | {c.document} | s.{c.section} | {c.title[:60]}")

t0 = time.time()
answer = gen.generate(QUESTION, chunks)
print(f"\n--- answer ({time.time()-t0:.1f}s) ---")
print(answer)
