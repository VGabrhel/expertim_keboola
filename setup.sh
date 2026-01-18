#!/bin/bash

# Script to set up Python 3.11 virtual environment and initialize git repository
set -e  # Exit on error

echo "🚀 Setting up Python 3.11 virtual environment and git repository..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Python 3.11 is available
check_python311() {
    if command -v python3.11 &> /dev/null; then
        PYTHON_CMD="python3.11"
        echo -e "${GREEN}✓ Python 3.11 found${NC}"
        return 0
    elif python3 --version | grep -q "3.11"; then
        PYTHON_CMD="python3"
        echo -e "${GREEN}✓ Python 3.11 found (via python3)${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠ Python 3.11 not found. Attempting to install...${NC}"
        return 1
    fi
}

# Try to install Python 3.11 using pyenv or homebrew
install_python311() {
    if command -v pyenv &> /dev/null; then
        echo "Installing Python 3.11 using pyenv..."
        pyenv install 3.11 -s
        pyenv local 3.11
        PYTHON_CMD="python3.11"
        echo -e "${GREEN}✓ Python 3.11 installed via pyenv${NC}"
        return 0
    elif command -v brew &> /dev/null; then
        echo "Installing Python 3.11 using Homebrew..."
        brew install python@3.11
        PYTHON_CMD="python3.11"
        echo -e "${GREEN}✓ Python 3.11 installed via Homebrew${NC}"
        return 0
    else
        echo -e "${RED}✗ Cannot install Python 3.11 automatically. Please install it manually.${NC}"
        echo "Options:"
        echo "  1. Install pyenv: curl https://pyenv.run | bash"
        echo "  2. Install Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        echo "  3. Download from https://www.python.org/downloads/"
        exit 1
    fi
}

# Check or install Python 3.11
if ! check_python311; then
    install_python311
fi

# Verify Python version
PYTHON_VERSION=$($PYTHON_CMD --version)
echo -e "${GREEN}Using: $PYTHON_VERSION${NC}"

# Check if uv is installed
check_uv() {
    if command -v uv &> /dev/null; then
        echo -e "${GREEN}✓ uv found${NC}"
        return 0
    elif [ -f "$HOME/.local/bin/uv" ]; then
        export PATH="$HOME/.local/bin:$PATH"
        echo -e "${GREEN}✓ uv found in ~/.local/bin${NC}"
        return 0
    elif [ -f "$HOME/.cargo/bin/uv" ]; then
        export PATH="$HOME/.cargo/bin:$PATH"
        echo -e "${GREEN}✓ uv found in ~/.cargo/bin${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠ uv not found. Installing uv...${NC}"
        return 1
    fi
}

# Install uv
install_uv() {
    if command -v curl &> /dev/null; then
        echo "Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        
        # Add uv to PATH - check both common installation locations
        if [ -f "$HOME/.local/bin/env" ]; then
            source "$HOME/.local/bin/env"
        elif [ -d "$HOME/.local/bin" ]; then
            export PATH="$HOME/.local/bin:$PATH"
        elif [ -d "$HOME/.cargo/bin" ]; then
            export PATH="$HOME/.cargo/bin:$PATH"
        fi
        
        # Verify uv is now available
        if command -v uv &> /dev/null; then
            echo -e "${GREEN}✓ uv installed${NC}"
            return 0
        fi
    fi
    echo -e "${RED}✗ Failed to install uv. Please install manually:${NC}"
    echo "  curl -LsSf https://astral.sh/uv/install.sh | sh"
    exit 1
}

# Check or install uv
if ! check_uv; then
    install_uv
    # Ensure uv is in PATH (check both locations)
    if [ -f "$HOME/.local/bin/env" ]; then
        source "$HOME/.local/bin/env"
    elif [ -d "$HOME/.local/bin" ] && ! command -v uv &> /dev/null; then
        export PATH="$HOME/.local/bin:$PATH"
    elif [ -d "$HOME/.cargo/bin" ] && ! command -v uv &> /dev/null; then
        export PATH="$HOME/.cargo/bin:$PATH"
    fi
fi

# Create virtual environment using uv
VENV_DIR="venv"
if [ -d "$VENV_DIR" ]; then
    echo -e "${YELLOW}⚠ Virtual environment already exists. Removing old one...${NC}"
    rm -rf "$VENV_DIR"
fi

echo "Creating virtual environment with uv..."
uv venv --python $PYTHON_CMD "$VENV_DIR"
echo -e "${GREEN}✓ Virtual environment created${NC}"

# Activate virtual environment
source "$VENV_DIR/bin/activate"
echo -e "${GREEN}✓ Virtual environment activated${NC}"

# Initialize git repository if not already initialized
if [ ! -d ".git" ]; then
    echo "Initializing git repository..."
    git init
    echo -e "${GREEN}✓ Git repository initialized${NC}"
else
    echo -e "${YELLOW}⚠ Git repository already exists${NC}"
fi

# Create .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    echo "Creating .gitignore..."
    cat > .gitignore << EOF
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual Environment
venv/
env/
ENV/
.venv

# uv
.uv/
uv.lock

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Environment variables
.env
.env.local
EOF
    echo -e "${GREEN}✓ .gitignore created${NC}"
fi

# Create pyproject.toml with data analysis packages if it doesn't exist
if [ ! -f "pyproject.toml" ]; then
    echo "Creating pyproject.toml with data analysis packages..."
    cat > pyproject.toml << EOF
[project]
name = "minimu-viable-python"
version = "0.1.0"
description = "Python 3.11 project with data analysis packages"
requires-python = ">=3.11"
dependencies = [
    "pandas>=2.0.0",
    "numpy>=1.24.0",
    "matplotlib>=3.7.0",
    "seaborn>=0.12.0",
    "scipy>=1.10.0",
    "jupyter>=1.0.0",
    "ipython>=8.12.0",
    "scikit-learn>=1.3.0",
    "openpyxl>=3.1.0",
    "plotly>=5.14.0",
]
EOF
    echo -e "${GREEN}✓ pyproject.toml created${NC}"
else
    echo -e "${YELLOW}⚠ pyproject.toml already exists${NC}"
fi

# Install packages using uv
echo "Installing data analysis packages with uv..."
uv pip install pandas numpy matplotlib seaborn scipy jupyter ipython scikit-learn openpyxl plotly
echo -e "${GREEN}✓ Data analysis packages installed${NC}"

# Create a basic README if it doesn't exist
if [ ! -f "README.md" ]; then
    echo "Creating README.md..."
    cat > README.md << EOF
# Python 3.11 Project

## Setup

Run the setup script to create a virtual environment and install packages:

\`\`\`bash
./setup.sh
\`\`\`

## Activate Virtual Environment

\`\`\`bash
source venv/bin/activate
\`\`\`

## Installed Packages

This project includes the following data analysis packages:
- pandas - Data manipulation and analysis
- numpy - Numerical computing
- matplotlib - Plotting library
- seaborn - Statistical data visualization
- scipy - Scientific computing
- jupyter - Interactive notebooks
- ipython - Enhanced interactive Python shell
- scikit-learn - Machine learning library
- openpyxl - Excel file support
- plotly - Interactive visualizations

## Deactivate Virtual Environment

\`\`\`bash
deactivate
\`\`\`
EOF
    echo -e "${GREEN}✓ README.md created${NC}"
fi

echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo "To activate the virtual environment, run:"
echo -e "${YELLOW}  source venv/bin/activate${NC}"
echo ""
echo "To deactivate, run:"
echo -e "${YELLOW}  deactivate${NC}"

