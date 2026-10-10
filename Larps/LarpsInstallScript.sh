ollama list | grep -q "llama3.2:1b" && echo "Installed"|| { echo "Not Installed"; ollama pull llama3.2:1b; }


ollama create Larps1.0:1b -f ./LarpsFile
