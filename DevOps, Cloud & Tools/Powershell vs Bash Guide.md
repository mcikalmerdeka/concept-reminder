# PowerShell vs Bash: A Complete Guide for Data Scientists & AI Engineers

## Table of Contents
1. [What is Shell Scripting?](#what-is-shell-scripting)
2. [PowerShell Overview](#powershell-overview)
3. [Bash Overview](#bash-overview)
4. [Why Learn Shell Scripting?](#why-learn-shell-scripting)
5. [Side-by-Side Comparison](#side-by-side-comparison)
6. [Your Script Example: PowerShell vs Bash](#your-script-example)
7. [Common Data Science Use Cases](#common-data-science-use-cases)
8. [Which Should You Learn?](#which-should-you-learn)
9. [Learning Path](#learning-path)

---

## What is Shell Scripting?

**Shell scripting** is writing a series of commands for a command-line interpreter (shell) to execute automatically. Instead of typing commands one by one, you write them in a file and run them all at once.

### Think of it as:
- **Automation** - Repeating tasks without manual intervention
- **Orchestration** - Coordinating multiple tools and programs
- **Workflow** - Creating pipelines for data processing, model training, deployment, etc.

### Real-world analogy:
If individual commands are like following cooking steps one at a time, a script is like having a complete recipe that you can execute with one command.

---

## PowerShell Overview

### What is PowerShell?

**PowerShell** is a modern shell and scripting language developed by Microsoft. It's built on the .NET framework and treats everything as objects (not just text).

### Key Characteristics:
- **Object-oriented** - Commands return objects with properties and methods
- **Verb-Noun naming** - Commands like `Get-Process`, `Set-Variable`, `Remove-Item`
- **Cross-platform** - Works on Windows, macOS, and Linux (PowerShell Core/7+)
- **Windows integration** - Deep integration with Windows systems and Active Directory
- **File extension** - `.ps1`

### Example:
```powershell
# Get all processes using more than 100MB of memory
Get-Process | Where-Object { $_.WorkingSet -gt 100MB } | Select-Object Name, Id
```

---

## Bash Overview

### What is Bash?

**Bash** (Bourne Again Shell) is the default shell for most Linux distributions and macOS. It's the standard scripting language for Unix-like systems.

### Key Characteristics:
- **Text-based** - Everything is treated as text streams
- **Universal** - Available on virtually all Unix/Linux systems
- **Simple syntax** - Straightforward for basic automation
- **Pipeline philosophy** - Chaining simple tools together
- **File extension** - `.sh`

### Example:
```bash
# Get all processes using more than 100MB of memory
ps aux | awk '$6 > 100000 { print $11, $2 }'
```

---

## Why Learn Shell Scripting?

### For Data Scientists:
1. **Data Pipeline Automation**
   - ETL workflows
   - Batch processing multiple datasets
   - Automated data validation

2. **File Management**
   - Organizing datasets
   - Batch renaming/moving files
   - Cleaning up temporary files

3. **Remote Server Work**
   - SSH into cloud instances
   - Running experiments on remote GPUs
   - Managing datasets on servers

4. **Reproducibility**
   - Document your workflow
   - Share reproducible analysis pipelines
   - Automate report generation

### For AI Engineers:
1. **Model Training Automation**
   - Schedule training jobs
   - Hyperparameter sweep scripts
   - Multi-GPU training orchestration

2. **Deployment Pipelines**
   - Containerization (Docker)
   - CI/CD for ML models
   - Automated testing

3. **Resource Management**
   - Monitor GPU usage
   - Manage cloud resources
   - Automated backups

4. **Environment Setup**
   - Reproducible development environments
   - Dependency management
   - Configuration management

---

## Side-by-Side Comparison

### Basic Syntax Comparison

| Feature | PowerShell | Bash |
|---------|------------|------|
| **File Extension** | `.ps1` | `.sh` |
| **Shebang Line** | Not required | `#!/bin/bash` |
| **Comments** | `# Comment` | `# Comment` |
| **Case Sensitive** | No | Yes |
| **Variables** | `$myVar = "value"` | `myVar="value"` (no spaces!) |
| **Command Style** | `Verb-Noun` | `lowercase-with-dashes` |

### Variables

**PowerShell:**
```powershell
# Declaring variables
$name = "John"
$age = 25
$isActive = $true

# Using variables
Write-Host "Hello, $name"
Write-Host "Age: $age"
```

**Bash:**
```bash
# Declaring variables (no spaces around =)
name="John"
age=25
is_active=true

# Using variables
echo "Hello, $name"
echo "Age: $age"
```

### Parameters/Arguments

**PowerShell:**
```powershell
param(
    [string]$name = "default",
    [int]$count = 1
)

Write-Host "Name: $name, Count: $count"
```

**Bash:**
```bash
# Access with $1, $2, $3, etc.
name=${1:-"default"}  # Default value if not provided
count=${2:-1}

echo "Name: $name, Count: $count"
```

### Conditional Statements

**PowerShell:**
```powershell
if ($age -gt 18) {
    Write-Host "Adult"
} elseif ($age -eq 18) {
    Write-Host "Just became adult"
} else {
    Write-Host "Minor"
}
```

**Bash:**
```bash
if [ $age -gt 18 ]; then
    echo "Adult"
elif [ $age -eq 18 ]; then
    echo "Just became adult"
else
    echo "Minor"
fi
```

### Loops

**PowerShell:**
```powershell
# For loop
for ($i = 0; $i -lt 5; $i++) {
    Write-Host $i
}

# ForEach loop
$files = Get-ChildItem *.txt
foreach ($file in $files) {
    Write-Host $file.Name
}

# While loop
$i = 0
while ($i -lt 5) {
    Write-Host $i
    $i++
}
```

**Bash:**
```bash
# For loop
for i in {0..4}; do
    echo $i
done

# ForEach loop (over files)
for file in *.txt; do
    echo $file
done

# While loop
i=0
while [ $i -lt 5 ]; do
    echo $i
    ((i++))
done
```

### Switch/Case Statements

**PowerShell:**
```powershell
switch ($action) {
    "start" { Write-Host "Starting..." }
    "stop" { Write-Host "Stopping..." }
    default { Write-Host "Unknown action" }
}
```

**Bash:**
```bash
case "$action" in
    start)
        echo "Starting..."
        ;;
    stop)
        echo "Stopping..."
        ;;
    *)
        echo "Unknown action"
        ;;
esac
```

### Functions

**PowerShell:**
```powershell
function Get-FileSize {
    param([string]$path)
    
    $file = Get-Item $path
    return $file.Length
}

$size = Get-FileSize "data.csv"
Write-Host "Size: $size bytes"
```

**Bash:**
```bash
get_file_size() {
    local path=$1
    
    size=$(stat -f%z "$path" 2>/dev/null || stat -c%s "$path")
    echo $size
}

size=$(get_file_size "data.csv")
echo "Size: $size bytes"
```

### Arrays

**PowerShell:**
```powershell
# Creating arrays
$fruits = @("apple", "banana", "orange")
$numbers = 1..10

# Accessing elements
Write-Host $fruits[0]  # apple
Write-Host $fruits[-1]  # orange (last element)

# Array operations
$fruits += "grape"  # Add element
$fruits.Length  # Get length
```

**Bash:**
```bash
# Creating arrays
fruits=("apple" "banana" "orange")
numbers=(1 2 3 4 5 6 7 8 9 10)

# Accessing elements
echo ${fruits[0]}  # apple
echo ${fruits[-1]}  # orange (last element)

# Array operations
fruits+=("grape")  # Add element
echo ${#fruits[@]}  # Get length
```

### Command Execution

**PowerShell:**
```powershell
# Run commands directly
Get-Process
docker ps

# Capture output
$output = Get-Process | Select-Object -First 5
$result = docker ps -a

# Execute external programs
& "C:\Program Files\Python\python.exe" script.py
```

**Bash:**
```bash
# Run commands directly
ps aux
docker ps

# Capture output
output=$(ps aux | head -5)
result=$(docker ps -a)

# Execute programs
python script.py
/usr/bin/python3 script.py
```

---

## Your Script Example

Let's look at your `dev.ps1` script and its Bash equivalent in detail:

### PowerShell Version (Your Original)

```powershell
# Development helper script for Windows PowerShell

param(
    [string]$action = "help"
)

switch ($action.ToLower()) {
    "start" {
        Write-Host "Starting development environment..." -ForegroundColor Green
        docker-compose -f docker-compose.dev.yml up -d
        Write-Host "Development server running at http://localhost:3111" -ForegroundColor Green
        Write-Host "Your changes will auto-reload!" -ForegroundColor Yellow
    }
    "stop" {
        Write-Host "Stopping development environment..." -ForegroundColor Red
        docker-compose -f docker-compose.dev.yml down
        Write-Host "Development environment stopped" -ForegroundColor Green
    }
    "restart" {
        Write-Host "Restarting development environment..." -ForegroundColor Yellow
        docker-compose -f docker-compose.dev.yml down
        docker-compose -f docker-compose.dev.yml up -d
        Write-Host "Development server restarted at http://localhost:3111" -ForegroundColor Green
    }
    "logs" {
        Write-Host "Showing development logs (Ctrl+C to exit)..." -ForegroundColor Blue
        docker-compose -f docker-compose.dev.yml logs -f
    }
    "build" {
        Write-Host "Building production version..." -ForegroundColor Magenta
        docker-compose down
        docker-compose up -d --build
        Write-Host "Production build complete at http://localhost:3000" -ForegroundColor Green
    }
    default {
        Write-Host "Development Helper Script" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Usage: .\dev.ps1 [action]" -ForegroundColor White
        Write-Host ""
        Write-Host "Actions:" -ForegroundColor Yellow
        Write-Host "  start   - Start development server with hot reload" -ForegroundColor Green
        Write-Host "  stop    - Stop development server" -ForegroundColor Red
        Write-Host "  restart - Restart development server" -ForegroundColor Yellow
        Write-Host "  logs    - View development logs" -ForegroundColor Blue
        Write-Host "  build   - Build and run production version" -ForegroundColor Magenta
        Write-Host "  help    - Show this help message" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Examples:" -ForegroundColor White
        Write-Host "  .\dev.ps1 start" -ForegroundColor Gray
        Write-Host "  .\dev.ps1 stop" -ForegroundColor Gray
        Write-Host "  .\dev.ps1 logs" -ForegroundColor Gray
    }
}
```

### Bash Equivalent

```bash
#!/bin/bash
# Development helper script for Bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

action=${1:-help}

case "$action" in
    start)
        echo -e "${GREEN}Starting development environment...${NC}"
        docker-compose -f docker-compose.dev.yml up -d
        echo -e "${GREEN}Development server running at http://localhost:3111${NC}"
        echo -e "${YELLOW}Your changes will auto-reload!${NC}"
        ;;
    stop)
        echo -e "${RED}Stopping development environment...${NC}"
        docker-compose -f docker-compose.dev.yml down
        echo -e "${GREEN}Development environment stopped${NC}"
        ;;
    restart)
        echo -e "${YELLOW}Restarting development environment...${NC}"
        docker-compose -f docker-compose.dev.yml down
        docker-compose -f docker-compose.dev.yml up -d
        echo -e "${GREEN}Development server restarted at http://localhost:3111${NC}"
        ;;
    logs)
        echo -e "${BLUE}Showing development logs (Ctrl+C to exit)...${NC}"
        docker-compose -f docker-compose.dev.yml logs -f
        ;;
    build)
        echo -e "${MAGENTA}Building production version...${NC}"
        docker-compose down
        docker-compose up -d --build
        echo -e "${GREEN}Production build complete at http://localhost:3000${NC}"
        ;;
    *)
        echo -e "${CYAN}Development Helper Script${NC}"
        echo ""
        echo -e "${WHITE}Usage: ./dev.sh [action]${NC}"
        echo ""
        echo -e "${YELLOW}Actions:${NC}"
        echo -e "  ${GREEN}start${NC}   - Start development server with hot reload"
        echo -e "  ${RED}stop${NC}    - Stop development server"
        echo -e "  ${YELLOW}restart${NC} - Restart development server"
        echo -e "  ${BLUE}logs${NC}    - View development logs"
        echo -e "  ${MAGENTA}build${NC}   - Build and run production version"
        echo -e "  ${CYAN}help${NC}    - Show this help message"
        echo ""
        echo -e "${WHITE}Examples:${NC}"
        echo -e "  ${GRAY}./dev.sh start${NC}"
        echo -e "  ${GRAY}./dev.sh stop${NC}"
        echo -e "  ${GRAY}./dev.sh logs${NC}"
        ;;
esac
```

### Key Differences Explained

| Element | PowerShell | Bash |
|---------|------------|------|
| **Shebang** | Not needed | `#!/bin/bash` required |
| **Parameters** | `param([string]$action = "help")` | `action=${1:-help}` |
| **Colors** | Built-in `-ForegroundColor` | ANSI escape codes defined manually |
| **Switch/Case** | `switch ($action.ToLower())` | `case "$action" in` |
| **Case blocks** | `{ }` | Ends with `;;` |
| **Default case** | `default` | `*)` |
| **Print** | `Write-Host` | `echo` or `echo -e` (for colors) |
| **Execution** | `.\dev.ps1 start` | `./dev.sh start` (needs execute permission) |

### How to Run Each

**PowerShell:**
```powershell
# No setup needed
.\dev.ps1 start
.\dev.ps1 stop
```

**Bash:**
```bash
# First time: make executable
chmod +x dev.sh

# Then run
./dev.sh start
./dev.sh stop
```

---

## Common Data Science Use Cases

### 1. Data Pipeline Automation

**PowerShell:**
```powershell
# Process multiple CSV files
Get-ChildItem *.csv | ForEach-Object {
    $filename = $_.Name
    Write-Host "Processing $filename..."
    python process_data.py $filename
    Move-Item $filename "processed/"
}
```

**Bash:**
```bash
# Process multiple CSV files
for file in *.csv; do
    echo "Processing $file..."
    python process_data.py "$file"
    mv "$file" processed/
done
```

### 2. Model Training Script

**PowerShell:**
```powershell
# Train model with different hyperparameters
$learning_rates = @(0.001, 0.01, 0.1)
$batch_sizes = @(32, 64, 128)

foreach ($lr in $learning_rates) {
    foreach ($bs in $batch_sizes) {
        Write-Host "Training with LR=$lr, BS=$bs"
        python train.py --lr $lr --batch-size $bs --output "models/model_lr${lr}_bs${bs}"
    }
}
```

**Bash:**
```bash
# Train model with different hyperparameters
learning_rates=(0.001 0.01 0.1)
batch_sizes=(32 64 128)

for lr in "${learning_rates[@]}"; do
    for bs in "${batch_sizes[@]}"; do
        echo "Training with LR=$lr, BS=$bs"
        python train.py --lr $lr --batch-size $bs --output "models/model_lr${lr}_bs${bs}"
    done
done
```

### 3. Environment Setup

**PowerShell:**
```powershell
# Setup new project environment
function Setup-DataScienceProject {
    param([string]$projectName)
    
    Write-Host "Creating project: $projectName"
    
    # Create directory structure
    New-Item -ItemType Directory -Path $projectName
    Set-Location $projectName
    
    New-Item -ItemType Directory -Path "data/raw"
    New-Item -ItemType Directory -Path "data/processed"
    New-Item -ItemType Directory -Path "notebooks"
    New-Item -ItemType Directory -Path "src"
    New-Item -ItemType Directory -Path "models"
    
    # Create virtual environment
    python -m venv venv
    
    # Create requirements.txt
    @"
pandas
numpy
scikit-learn
matplotlib
jupyter
"@ | Out-File -FilePath requirements.txt
    
    Write-Host "Project $projectName created successfully!"
}
```

**Bash:**
```bash
# Setup new project environment
setup_data_science_project() {
    local project_name=$1
    
    echo "Creating project: $project_name"
    
    # Create directory structure
    mkdir -p "$project_name"/{data/{raw,processed},notebooks,src,models}
    cd "$project_name"
    
    # Create virtual environment
    python -m venv venv
    
    # Create requirements.txt
    cat > requirements.txt << EOF
pandas
numpy
scikit-learn
matplotlib
jupyter
EOF
    
    echo "Project $project_name created successfully!"
}
```

### 4. Automated Testing

**PowerShell:**
```powershell
# Run tests and generate report
Write-Host "Running unit tests..." -ForegroundColor Yellow
pytest tests/ --verbose

Write-Host "Running data validation..." -ForegroundColor Yellow
python validate_data.py

Write-Host "Checking code quality..." -ForegroundColor Yellow
flake8 src/

if ($LASTEXITCODE -eq 0) {
    Write-Host "All tests passed!" -ForegroundColor Green
} else {
    Write-Host "Tests failed!" -ForegroundColor Red
    exit 1
}
```

**Bash:**
```bash
# Run tests and generate report
echo "Running unit tests..."
pytest tests/ --verbose

echo "Running data validation..."
python validate_data.py

echo "Checking code quality..."
flake8 src/

if [ $? -eq 0 ]; then
    echo "All tests passed!"
else
    echo "Tests failed!"
    exit 1
fi
```

### 5. Remote GPU Training

**Bash (More common for remote servers):**
```bash
#!/bin/bash
# Submit training job to remote GPU server

SERVER="gpu-server.example.com"
GPU_ID=${1:-0}

echo "Submitting job to GPU $GPU_ID on $SERVER..."

ssh $SERVER << EOF
    export CUDA_VISIBLE_DEVICES=$GPU_ID
    cd /home/user/project
    source venv/bin/activate
    nohup python train.py --config config.yaml > logs/train_gpu${GPU_ID}.log 2>&1 &
    echo "Training started on GPU $GPU_ID"
EOF

echo "Job submitted. Check logs with: ssh $SERVER 'tail -f /home/user/project/logs/train_gpu${GPU_ID}.log'"
```

### 6. Data Backup Script

**PowerShell:**
```powershell
# Backup important data
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$backup_name = "backup_$timestamp"

Write-Host "Creating backup: $backup_name"

# Compress data directory
Compress-Archive -Path "data/", "models/", "notebooks/" -DestinationPath "backups/$backup_name.zip"

# Upload to cloud (example with AWS CLI)
aws s3 cp "backups/$backup_name.zip" "s3://my-bucket/backups/"

Write-Host "Backup completed: $backup_name.zip"
```

**Bash:**
```bash
# Backup important data
timestamp=$(date +%Y-%m-%d_%H-%M-%S)
backup_name="backup_$timestamp"

echo "Creating backup: $backup_name"

# Create tar archive
tar -czf "backups/$backup_name.tar.gz" data/ models/ notebooks/

# Upload to cloud (example with AWS CLI)
aws s3 cp "backups/$backup_name.tar.gz" "s3://my-bucket/backups/"

echo "Backup completed: $backup_name.tar.gz"
```

---

## Which Should You Learn?

### Choose PowerShell if:
- ✅ You work primarily on Windows
- ✅ You need deep Windows system integration
- ✅ You prefer object-oriented programming
- ✅ You work with .NET applications
- ✅ You manage Windows servers

### Choose Bash if:
- ✅ You deploy to Linux servers (AWS, GCP, Azure VMs)
- ✅ You work with Docker/Kubernetes
- ✅ You use CI/CD pipelines (GitHub Actions, GitLab CI)
- ✅ You SSH into remote machines frequently
- ✅ You work in data centers or cloud environments

### Learn Both if:
- ✅ You develop on Windows but deploy to Linux
- ✅ You work in heterogeneous environments
- ✅ You want maximum flexibility
- ✅ You're serious about DevOps/MLOps

**Recommendation for Data Scientists/AI Engineers:**
Start with whatever matches your primary OS, but **aim to learn both eventually**. Bash is more universal for production environments, but PowerShell is excellent for Windows-based data work.

---

## Learning Path

### Week 1-2: Basics
1. **Variables and data types**
2. **Basic commands** (file operations, navigation)
3. **Input/output**
4. **Comments and documentation**

### Week 3-4: Control Flow
1. **If/else statements**
2. **Switch/case**
3. **Loops** (for, while, foreach)
4. **Functions**

### Week 5-6: Intermediate
1. **Arrays and collections**
2. **String manipulation**
3. **Error handling**
4. **File I/O operations**

### Week 7-8: Advanced
1. **Regular expressions**
2. **Piping and redirections**
3. **Process management**
4. **Parallel execution**

### Week 9-10: Real Projects
1. **Data pipeline automation**
2. **Environment setup scripts**
3. **Testing automation**
4. **Deployment scripts**

---

## Quick Reference Cheat Sheet

### File Operations

| Task | PowerShell | Bash |
|------|------------|------|
| List files | `Get-ChildItem` or `ls` | `ls` or `ls -la` |
| Copy file | `Copy-Item src dst` | `cp src dst` |
| Move file | `Move-Item src dst` | `mv src dst` |
| Delete file | `Remove-Item file` | `rm file` |
| Create directory | `New-Item -ItemType Directory` | `mkdir dirname` |
| Find files | `Get-ChildItem -Recurse -Filter "*.py"` | `find . -name "*.py"` |

### Text Processing

| Task | PowerShell | Bash |
|------|------------|------|
| Search in files | `Select-String "pattern" file` | `grep "pattern" file` |
| Count lines | `(Get-Content file).Count` | `wc -l file` |
| Replace text | `(Get-Content file) -replace "old","new"` | `sed 's/old/new/g' file` |
| Get first N lines | `Get-Content file -First 10` | `head -n 10 file` |
| Get last N lines | `Get-Content file -Last 10` | `tail -n 10 file` |

### System Information

| Task | PowerShell | Bash |
|------|------------|------|
| Current directory | `Get-Location` or `pwd` | `pwd` |
| Environment vars | `$env:VARIABLE` | `$VARIABLE` or `${VARIABLE}` |
| Process list | `Get-Process` | `ps aux` |
| Disk usage | `Get-PSDrive` | `df -h` |
| Current user | `$env:USERNAME` | `whoami` or `$USER` |

---

## Best Practices

### General Scripting Best Practices

1. **Always add comments** explaining what your script does
2. **Use meaningful variable names** (not `$x`, `$y`, `$z`)
3. **Handle errors gracefully** with try-catch or error checking
4. **Make scripts reusable** with parameters/arguments
5. **Test incrementally** don't write everything at once
6. **Version control** keep scripts in Git
7. **Document usage** include help text in your scripts

### PowerShell Specific

1. Use approved verbs (`Get-`, `Set-`, `New-`, etc.)
2. Use `Write-Host` for user messages, not `Write-Output`
3. Use `-WhatIf` and `-Confirm` for destructive operations
4. Follow PascalCase for function names
5. Use parameter validation attributes

### Bash Specific

1. Always quote variables: `"$variable"` not `$variable`
2. Use `#!/bin/bash` shebang
3. Make scripts executable: `chmod +x script.sh`
4. Check command success: `if [ $? -eq 0 ]`
5. Use `set -e` to exit on errors
6. Use lowercase for variable names

---

## Conclusion

Both PowerShell and Bash are powerful tools for automation in data science and AI engineering. Your existing PowerShell knowledge gives you a great foundation - the concepts transfer directly to Bash with just syntax differences.

**Key Takeaways:**
- Same purpose, different syntax
- PowerShell = Windows-centric, object-oriented
- Bash = Unix/Linux universal standard
- Both useful for data science automation
- Learn the one matching your primary environment first
- Eventually learn both for maximum flexibility

**Next Steps:**
1. Practice converting simple PowerShell scripts to Bash
2. Automate one repetitive task in your workflow
3. Build a project setup script
4. Create a data processing pipeline
5. Contribute to open-source projects to see real-world usage

Happy scripting! 🚀