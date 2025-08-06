# Comprehensive Documention: Dossier-Graph


## Implementation steps

Here is a step by step description of how to implement the Dossier-Graph on your system (assuming UBUNTU 24 LTS).

## Model Fine-Tuning to IQWiG Domain Knowledge

We're essentially showing the AI thousands of examples of "this is how IQWiG experts write" and letting it learn the statistical patterns, then applying those patterns to new situations.

#### STEP 1:  Data Preparation
Convert HTA Reports to Training Examples
FOR each IQWiG report:
    extract_text_from_pdf(report.pdf)
    
    // Essential: Create question-answer pairs
    training_example = {
        question: "Summarize the benefit assessment for [drug name]"
        context: "IQWiG report A23-42: Methods section... Results section..."  
        answer: "The assessment concluded considerable additional benefit..."
    }
    
    // Essential: Use IQWiG's exact format
    format_as_conversation(training_example)
    // "[INST] Question + Context [/INST] Answer"

WHY ESSENTIAL: The AI learns by seeing thousands of examples of "good HTA writing"

#### STEP 2: Model Setup
Load Base AI Model
base_model = load_mistral_7b()  // 7 billion parameters
compress_model_to_4bit()        // Reduces memory from 28GB to 7GB


#### STEP 3: Apply LoRA Modification
// Essential: Only modify specific parts, not entire model
target_layers = ["attention_weights", "output_projections"] 
FOR each target_layer:
    add_small_adjustment_matrix(layer, size=64)  // 64 parameters vs 4 million

WHY ESSENTIAL: We're not retraining the entire AI (impossible), just teaching it 
HTA-specific patterns by adding tiny "adjustment dials"


#### STEP 4: Training Loop
FOR 3 complete_passes_through_data:
    FOR each training_example:
        
        // Feed the AI the question + context
        prediction = model.generate_answer(question + context)
        
        // Compare to correct HTA answer
        error = calculate_difference(prediction, correct_answer)
        
        // Essential: Adjust only the LoRA parameters
        adjust_small_matrices(error_signal)
        // Original model stays frozen!
        
#### STEP 5: Validation  
EVERY 100 examples:
    test_on_holdout_reports()
    IF error_increasing:
        stop_training()  // Prevent overfitting

WHY ESSENTIAL: Like teaching someone to write in IQWiG style - show examples, 
give feedback, adjust gradually

#### STEP 6: Using the Trained Model
user_question = "Assess the evidence quality for pembrolizumab in melanoma"
user_context = "Single RCT, n=834 patients, 22-month follow-up..."

// Essential: Format exactly like training
formatted_input = "[INST] " + user_question + "\n\nContext: " + user_context + " [/INST]"

// Model processing (simplified)
tokens = convert_text_to_numbers(formatted_input)
FOR each position in sequence:
    // Base model generates medical knowledge
    base_probabilities = mistral_base_model(tokens)
    
    // LoRA adjustments add HTA-specific patterns  
    hta_adjustments = lora_matrices(tokens)
    final_probabilities = base_probabilities + hta_adjustments
    
    next_word = sample_from_probabilities(final_probabilities)
    tokens.append(next_word)

response = convert_numbers_to_text(tokens)

WHY ESSENTIAL: The base model provides general medical knowledge, 
LoRA adds IQWiG-specific writing patterns

## Essential Concepts

#### 1: Pattern Matching at Scale

// The AI learns patterns like:
IF user_asks_about("evidence quality") AND context_mentions("single RCT"):
    response_should_include("limitations of single-study evidence")
    response_should_mention("need for replication") 
    response_should_use_GRADE_terminology()


#### 2: Mathematical Optimization

// Training is essentially:
REPEAT millions_of_times:
    wrong_answer = "The study was good"  // Too vague
    correct_answer = "The study provides moderate-quality evidence (GRADE: moderate)"
    
    error = correct_answer - wrong_answer
    adjustment = error * learning_rate * 0.0002
    model_parameters += adjustment
    
#### 3: Why LoRA Works

// Instead of changing 7 billion parameters:
original_layer = Matrix[4096 x 4096]  // 16 million numbers
lora_layer = MatrixA[4096 x 64] * MatrixB[64 x 4096]  // Only 524k numbers

// During inference:
output = original_layer(input) + lora_layer(input)
// 99.7% original knowledge + 0.3% HTA-specific adjustments


## Critical Factors

#### Data Quality: Bad examples → Bad AI ("Garbage In -- Garbage Out")

IF training_data_contains("inconsistent terminology"):
    model_will_learn("inconsistent patterns")
    
#### Sufficient Examples: Need 500+ examples per task type

evidence_assessment_examples = 50   // Too few
benefit_rating_examples = 200       // Sufficient  
cost_effectiveness_examples = 100   // Borderlin


#### Proper Validation: Must test on unseen IQWiG reports

training_reports = reports[0:80%]    // Learn from these
test_reports = reports[80:100%]      // Evaluate on these
IF test_performance < acceptable_threshold:
    need_more_data_or_different_approach()
