import multiprocessing
import subprocess
from threading import Thread
import os

compiler = "/Users/sergiuiacob/Downloads/solc-v0.8.14"
compiler_star = "/Users/sergiuiacob/solidity-uae-enhancement/build/solc/solc"

etherscan_dataset_path = "/Users/sergiuiacob/solidity-optimization-with-control-flow-graphs/etherscan_dataset"
files = os.listdir(etherscan_dataset_path)

print(f"There are {len(files)} files")

def compile_contract(compiler, args):
    child = subprocess.Popen([compiler, *args],stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = child.communicate(timeout=60)
    return child.returncode, stdout.decode("utf-8"), stderr.decode("utf-8")

def compare_compilation_result(file):
    path = os.path.join(etherscan_dataset_path, file)
    command_args = ["--gas", "--optimize", "--via-ir", "--yul-optimizations", "Dru", path]

    return_code_star, stdout_star, stderr_star = compile_contract(compiler_star, command_args)
    return_code, stdout, stderr = compile_contract(compiler, command_args)
    
    if stderr_star == "" and stderr != "":
        print("stderr difference", path)
    if stdout_star != stdout:
        print("stdout difference", path)
    if return_code_star != return_code:
        print("return_code difference", path)


def count_compilable_contracts():
    good = 0
    for file in files:
        path = os.path.join(etherscan_dataset_path, file)
        code, _, _ = compile_contract(compiler, [path])
        good += code == 0
        print(good)


count_compilable_contracts()

# pool = multiprocessing.Pool(processes=2)
# pool.map(compare_compilation_result, files)
# pool.close()
# x = pool.join()
# print(x)
