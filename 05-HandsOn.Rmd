# Dossier-Graph: Model Fine-Tuning for IQWiG Domain Knowledge {#dossier-graph}

## Overview {#overview}

This guide provides comprehensive instructions for implementing the Dossier-Graph system, which creates a specialized AI assistant for Health Technology Assessment (HTA) tasks. The system fine-tunes large language models to understand and generate content following IQWiG (Institute for Quality and Efficiency in Health Care) standards.

### System Requirements {#system-requirements}

- **Operating System**: Ubuntu 24 LTS (recommended)
- **Memory**: Minimum 16GB RAM
- **GPU**: NVIDIA GPU with 8-12GB VRAM
- **Storage**: 50GB available space
- **Python**: Version 3.8 or higher

### Core Capabilities {#core-capabilities}

The fine-tuned model will be helpful in assisting to:

- Generate HTA summaries following IQWiG methodology standards
- Evaluate evidence quality using IQWiG terminology
- Draft benefit assessments with appropriate regulatory language
- Analyze cost-effectiveness in accessible terms
- Provide methodological guidance based on IQWiG precedents
- Process both German and English HTA content

## Implementation Architecture {#implementation-architecture}

### Technical Stack {#technical-stack}

- **Base Model**: Mistral-7B-v0.1 (7 billion parameters)
- **Fine-tuning Method**: LoRA (Low-Rank Adaptation)
- **Quantization**: 4-bit precision for memory efficiency
- **Framework**: Hugging Face Transformers with PEFT

### LoRA Configuration {#lora-configuration}

```python
target_modules = [
    "q_proj", "k_proj", "v_proj", "o_proj",  # Attention layers
    "gate_proj", "up_proj", "down_proj",     # MLP layers  
    "lm_head"                                 # Output projection
]

lora_config = {
    "r": 64,                # Rank for medical terminology complexity
    "alpha": 128,           # 2x rank ratio for training stability
    "dropout": 0.05,        # Lower dropout for specialized domain
    "bias": "none"          # Standard for causal language models
}
```

## Data Preparation Pipeline {#data-preparation}

### Step 1: Document Processing {#document-processing}

Convert IQWiG reports into structured training data:

```python
def process_hta_report(report_path):
    """Extract and structure content from IQWiG reports."""
    
    # Extract text from PDF
    text_content = extract_text_from_pdf(report_path)
    
    # Create instruction-based training examples
    training_example = {
        "instruction": "Summarize the benefit assessment findings",
        "input": f"IQWiG Report {report_id}: {text_content}",
        "output": "The assessment concluded..."
    }
    
    return format_as_jsonl(training_example)
```

### Step 2: Training Data Structure {#training-data-structure}

Each training example follows this JSONL format:

```json
{
  "instruction": "Evaluate the evidence quality for pembrolizumab in melanoma",
  "input": "Single RCT, n=834 patients, 22-month follow-up, primary endpoint: PFS",
  "output": "The evidence quality is rated as moderate (GRADE). While the single RCT provides robust data with adequate sample size and follow-up duration, the limitation to a single study reduces confidence in the generalizability of findings."
}
```

### Data Requirements {#data-requirements}

| Task Type | Minimum Examples | Recommended |
|:----------|:----------------|:------------|
| Evidence Assessment | 200 | 500+ |
| Benefit Rating | 200 | 400+ |
| Cost-Effectiveness Analysis | 150 | 300+ |
| Methodology Evaluation | 100 | 250+ |

## Model Training Process {#model-training}

### Step 1: Environment Setup {#environment-setup}

```bash
# Install required packages
pip install torch transformers peft trl datasets accelerate bitsandbytes

# Load and compress base model
from transformers import AutoModelForCausalLM, BitsAndBytesConfig

quantization_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_compute_dtype=torch.float16,
    bnb_4bit_quant_type="nf4"
)

model = AutoModelForCausalLM.from_pretrained(
    "mistralai/Mistral-7B-v0.1",
    quantization_config=quantization_config,
    device_map="auto"
)
```

### Step 2: LoRA Application {#lora-application}

The LoRA method adds small, trainable matrices to specific model layers:

```python
from peft import get_peft_model, LoraConfig

peft_config = LoraConfig(
    task_type="CAUSAL_LM",
    target_modules=target_modules,
    r=64,
    lora_alpha=128,
    lora_dropout=0.05
)

model = get_peft_model(model, peft_config)
# Trainable parameters: ~0.3% of original model
```

### Step 3: Training Loop {#training-loop}

```python
training_args = TrainingArguments(
    num_train_epochs=3,
    per_device_train_batch_size=4,
    gradient_accumulation_steps=4,
    learning_rate=2e-4,
    warmup_steps=100,
    logging_steps=25,
    save_strategy="epoch",
    evaluation_strategy="steps",
    eval_steps=100
)

trainer = SFTTrainer(
    model=model,
    train_dataset=train_dataset,
    eval_dataset=eval_dataset,
    args=training_args,
    max_seq_length=2048
)

trainer.train()
```

## Model Validation {#model-validation}

### Evaluation Metrics {#evaluation-metrics}

#### 1. **Perplexity**
**What it measures**: How "surprised" the model is by unseen HTA text - lower scores mean better prediction.

**Rationale**: Perplexity quantifies whether the model has genuinely learned HTA language patterns. If a model achieves low perplexity on held-out IQWiG reports, it demonstrates it can predict the next word in HTA contexts accurately. For example, after "The evidence quality is rated as", a well-trained model should predict "moderate" or "high" (low perplexity), not random medical terms (high perplexity).

**Why essential**: It's an objective, automated metric that catches overfitting - if perplexity is low on training data but high on validation data, the model memorized rather than learned.

#### 2. **ROUGE Scores**
**What it measures**: Overlap between generated summaries and expert-written reference summaries (word/phrase matching).

**Rationale**: HTA reports require precise summarization of complex evidence. ROUGE scores (Recall-Oriented Understudy for Gisting Evaluation) compare the model's summaries against gold-standard IQWiG summaries, measuring whether key phrases like "considerable additional benefit" or "hint of lesser benefit" appear correctly. ROUGE-L specifically captures longest common sequences, ensuring the model maintains IQWiG's logical flow.

**Why essential**: Validates that the model can distill lengthy clinical evidence into concise, accurate assessments matching IQWiG's standardized summary style.

#### 3. **Domain-Specific Accuracy**
**What it measures**: Correct usage of IQWiG-specific terminology and methodological concepts.

**Rationale**: IQWiG uses precise regulatory language with specific meanings. The model must distinguish between "proof" vs "indication" vs "hint" of benefit (Beleg/Hinweis/Anhaltspunkt in German), use GRADE terminology correctly, and apply the right benefit categories. This metric tests terminology on a curated test set - for instance, given specific evidence, does the model correctly classify it as "major" vs "considerable" additional benefit?

**Why essential**: Generic medical language isn't sufficient for regulatory submissions. Misusing terms like "significant benefit" instead of IQWiG's exact categories could invalidate an assessment.

#### 4. **Human Expert Review**
**What it measures**: Qualitative assessment of readability, logical coherence, and regulatory appropriateness.

**Rationale**: Automated metrics miss critical nuances that HTA professionals immediately recognize. Experts evaluate whether the model's outputs would be acceptable in actual IQWiG proceedings - checking for logical argumentation, appropriate hedging language, correct interpretation of statistical significance vs clinical relevance, and adherence to IQWiG's methodological standards that aren't captured by word matching.

**Why essential**: The ultimate test is whether HTA professionals would trust and use the output. Expert review catches dangerous errors (like misinterpreting non-inferiority trials) that automated metrics might miss.

#### Combined Rationale

These four metrics create a comprehensive evaluation framework:
- **Perplexity** ensures fundamental language modeling capability
- **ROUGE** validates content accuracy and completeness  
- **Domain Accuracy** confirms regulatory compliance
- **Expert Review** provides the final quality gate

Together, they prevent deploying a model that seems statistically competent but fails in real HTA contexts - a critical safety requirement for regulatory healthcare applications.

### Validation Strategy {#validation-strategy}

```python
# Split data: 80% training, 20% validation
train_reports = reports[:int(0.8 * len(reports))]
val_reports = reports[int(0.8 * len(reports)):]

# Test on unseen reports
validation_results = model.evaluate(val_reports)

if validation_results['perplexity'] > threshold:
    # Consider increasing training data or adjusting hyperparameters
    optimize_training_parameters()
```

## Deployment and Inference {#deployment}

### Model Usage {#model-usage}

```python
def generate_hta_response(question, context):
    """Generate HTA-compliant responses."""
    
    # Format input following training schema
    prompt = f"[INST] {question}\n\nContext: {context} [/INST]"
    
    # Tokenize and generate
    inputs = tokenizer(prompt, return_tensors="pt")
    outputs = model.generate(
        inputs.input_ids,
        max_new_tokens=512,
        temperature=0.7,
        do_sample=True,
        top_p=0.95
    )
    
    return tokenizer.decode(outputs[0], skip_special_tokens=True)
```

### Example Applications {#example-applications}

```python
# Evidence quality assessment
response = generate_hta_response(
    question="Assess the evidence quality for this intervention",
    context="Two RCTs (n=1,245 total), 12-month follow-up, consistent findings"
)

# Benefit summary generation
response = generate_hta_response(
    question="Summarize the additional benefit assessment",
    context="IQWiG Report A23-42: Primary endpoint met, QoL improved..."
)
```

## Critical Success Factors {#success-factors}

### Data Quality {#data-quality}

- **Consistency**: Ensure uniform terminology across training examples
- **Completeness**: Include all relevant IQWiG assessment types
- **Accuracy**: Verify expert annotations before training

### Technical Considerations {#technical-considerations}

1. **Memory Management**: 4-bit quantization reduces VRAM from 28GB to 7GB
2. **Training Stability**: Gradient accumulation enables larger effective batch sizes
3. **Overfitting Prevention**: Regular validation on held-out reports

### Performance Optimization {#performance-optimization}

| Parameter | Impact | Recommended Value |
|:----------|:-------|:-----------------|
| Learning Rate | Training stability | 2e-4 to 5e-4 |
| LoRA Rank (r) | Model capacity | 32-64 for medical domain |
| Batch Size | Memory usage | 4-8 with gradient accumulation |
| Training Epochs | Model performance | 3-5 (monitor validation loss) |

## Mathematical Foundation {#mathematical-foundation}

### LoRA Mechanism {#lora-mechanism}

Instead of updating all model parameters, LoRA introduces low-rank decomposition:

$$W_{new} = W_{original} + BA$$

Where:
- $W_{original}$ ∈ ℝ^{d×k} (frozen pre-trained weights)
- $B$ ∈ ℝ^{d×r} and $A$ ∈ ℝ^{r×k} (trainable matrices)
- $r << min(d, k)$ (rank constraint)

This reduces trainable parameters from O(dk) to O(r(d+k)), typically a 99.7% reduction.

### Training Objective {#training-objective}

The model optimizes cross-entropy loss over HTA-specific tokens:

$$L = -\sum_{i=1}^{N} \log P(y_i | x_{<i}, \theta_{base} + \Delta\theta_{LoRA})$$

Where $\Delta\theta_{LoRA}$ represents the small parameter updates learned from IQWiG data.

## Installation Guide {#installation}

### Quick Start {#quick-start}

Do not run: work in progress!

```bash
# Clone repository
git clone https://github.com/your-org/dossier-graph.git
cd dossier-graph

# Create virtual environment
python -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run training pipeline
python train_mistral_lora_hta.py \
    --data_path ./data/iqwig_reports \
    --output_dir ./models/hta_mistral \
    --num_epochs 3
```

### Production Deployment {#production-deployment}

For production environments, consider:

1. **API Service**: Deploy model behind REST API for scalability
2. **Batch Processing**: Implement queue system for high-volume requests
3. **Monitoring**: Track inference latency and model performance metrics
4. **Version Control**: Maintain model versioning for reproducibility

## Troubleshooting {#troubleshooting}

### Common Issues {#common-issues}

| Issue | Cause | Solution |
|:------|:------|:---------|
| Out of Memory | Large batch size | Reduce batch size or increase gradient accumulation |
| Poor Performance | Insufficient data | Increase training examples or use data augmentation |
| Overfitting | Too many epochs | Implement early stopping based on validation loss |
| Slow Training | Inefficient settings | Enable mixed precision training (fp16) |

## Conclusion {#conclusion}

The Dossier-Graph system enables organizations to create specialized AI assistants that understand and generate HTA content following IQWiG standards. By leveraging LoRA fine-tuning on carefully curated datasets, the system achieves domain expertise while maintaining computational efficiency.

### Next Steps {#next-steps}

1. Collect and prepare IQWiG reports for training
2. Set up development environment following this guide
3. Train initial model and evaluate performance
4. Iterate based on domain expert feedback
5. Deploy for production use

## References {#references}

- Hu, E. J., et al. (2021). LoRA: Low-Rank Adaptation of Large Language Models. arXiv:2106.09685
- IQWiG Methods Papers and Guidelines: www.iqwig.de
- Hugging Face PEFT Documentation: https://huggingface.co/docs/peft
