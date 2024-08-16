# Machine Learning

*Machine learning refers to a set of techniques and algorithms that enable computers to automatically learn from data and improve their performance on a specific task over time. Types of machine learning methods include, but are not limited to, supervised learning (algorithms trained on labeled datasets), unsupervised learning (algorithms trained on unlabeled datasets), and reinforcement learning (learning by trial and error). The Computational Science Center at NREL conducts research in these types of machine learning, and also supports the use of machine learning software on Kestrel.*

## Getting Started

<!-- TODO: Add link to NREL conda documentation. -->
This section provides basic examples for getting started with two popular machine learning libraries: [PyTorch](https://pytorch.org/) and [TensorFlow](https://www.tensorflow.org/). Both examples use [Anaconda environments](https://www.anaconda.com/), so if you are not familiar with their use please refer to the NREL HPC page on using Conda environments and also the Conda guide to [managing environments](https://conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html). 

###Getting started with PyTorch

To begin, we will outline basic steps for building a simple CPU-based conda environment for PyTorch. First, load the anaconda module and create a new conda environment:
```
module load anaconda3

conda create -p /projects/YOUR_PROJECT/YOUR_USER_NAME_HERE/FOLDER_FOR_CONDA_ENVIRONMENTS/pt python=3.9
```
Answer yes to proceed, and you should end up with directions for starting your conda environment pt. Note that these instructions place your environment in the specified /projects folder. This is advisable, as opposed to installing conda environments in their default location in your home directory. See our [Conda documentation](../Environment/Customization/conda.md#where-to-store-conda-environments) for more information.

Activate the pt conda environment and install PyTorch into the active conda environment:
```
conda activate /projects/YOUR_PROJECT/YOUR_USER_NAME_HERE/FOLDER_FOR_CONDA_ENVIRONMENTS/pt

conda install pytorch torchvision torchaudio cpuonly -c pytorch
```
Answer yes to proceed, and you should be up and running with PyTorch! The [PyTorch](https://pytorch.org/) webpage has great resources for getting started, including resources on [learning the basics](https://pytorch.org/tutorials/beginner/basics/intro.html) and [PyTorch recipes](https://pytorch.org/tutorials/recipes/recipes_index.html).

###Getting started with TensorFlow

Getting started with TensorFlow is similar to the process for PyTorch. The first step is to construct an empty conda environment to work in:
```
module load anaconda3

conda create -p /projects/YOUR_PROJECT/YOUR_USER_NAME_HERE/FOLDER_FOR_CONDA_ENVIRONMENTS/tf python=3.9
```
Subsequently, activate the tf conda environment, ensure you are running the latest version of pip in your environment, and install the CPU only version of TensorFlow using pip:
```
conda activate /projects/YOUR_PROJECT/YOUR_USER_NAME_HERE/FOLDER_FOR_CONDA_ENVIRONMENTS/tf
pip install --upgrade pip
pip install tensorflow-cpu
```
You should now be up and running with a TensorFlow! Similar to PyTorch, the [TensorFlow webpage](https://www.tensorflow.org/learn) has lots of great resources for getting started, including turotials, basic examples, and more! 


### Example Job Script

??? example "PyTorch or TensorFlow CPU"
	```
	#!/bin/bash 
	#SBATCH --nodes=1			# Run the tasks on the same node
	#SBATCH --time=1:00:00			# Required, estimate 1 hour
	#SBATCH --account=<your_account>
	#SBATCH --exclusive			# if you want to use the whole node

	module load anaconda3 

	cd /projects/<your_project_here>/<your_code_directory>

	conda activate /projects/<your_project_here>/<folder_for_conda_envs>/pt #or tf

	srun python your_pt_code.py

	```
!!! note
	This Getting Started section is only scratching the surface of ML libraries and resources that can be used on Kestrel. Tools such as LightGBM, XGBoost, and scikit-learn work well with conda environments, and other tools such as Flux for the Julia Language can be used on Kestrel as well.

Once you have completed your batch file, submit using
```
sbatch <your_batch_file_name>.sb
```

## Advanced (GPU)

The above examples are simple CPU-based computing environments. The following section covers how to build and run PyTorch for use with GPUs on Kestrel. For TensorFlow, we refer you to the [TensorFlow](https://www.tensorflow.org/install) install directions. 

For optimized TensorFlow performance, we recommend using a [containerized version of TensorFlow](Containerized_TensorFlow/index.md). 

### Installing PyTorch on Kestrel

To install PyTorch for use with GPUs on Kestrel, the first step is to load the anaconda module on the GPU node using ```module load conda```. Once the anaconda module has been loaded, create a new environment in which to install PyTorch, e.g.,

??? example "Creating and activating a new conda environment"
        conda create --prefix /projects/<your-project-name>/<your-user-name>/<conda-env-dir>/pt python=3.9
        conda activate /projects/<your-project-name>/<your-user-name>/<conda-env-dir>/pt

!!! Note
	If you are not familiar with using [Anaconda environments](https://www.anaconda.com/) please refer to the [NREL HPC page on using Conda environments](../Environment/Customization/conda.md) and also the Conda guide to [managing environments](https://conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html).

Once the environment has been activated, you can install PyTorch using the standard approach found under the Get Started tab of the [PyTorch](https://pytorch.org/) website, e.g., using ```pip```,

??? example "Installing PyTorch using pip"
	```pip3 install torch torchvision torchaudio```

!!! Note
	We recommend installing software for GPU jobs using the GPU nodes. There are two [GPU login nodes](../Systems/Kestrel/index.md) available on Kestrel. 

### Running a PyTorch Batch Job on Kestrel - GPU

??? example "Sample job script: Kestrel - Shared (partial) GPU node"

    ```
    #!/bin/bash
    #SBATCH --account=<your-account-name> 
    #SBATCH --nodes=1
    #SBATCH --gpus=h100:1 
    #SBATCH --ntasks-per-node=1
    #SBATCH --cpus-per-task=1
    #SBATCH --time=02:00:00
    #SBATCH --job-name=<your-job-name>

    module load conda
    conda activate /projects/<your-project-name>/<your-user-name>/<conda-env-dir>/pt

    srun python <your-pytorch-code>.py
    ```

### PyTorch Example
Below we present a simple convolutional neural network example for getting started using PyTorch with Kestrel GPUs. The original, more detailed version of this example can be found in the pytorch tutorials repo [here](https://github.com/pytorch/tutorials/blob/main/beginner_source/blitz/cifar10_tutorial.py).

??? example "CIFAR10 example"
    ```
    import torch
    import torchvision
    import torchvision.transforms as transforms
    import torch.nn as nn
    import torch.nn.functional as F
    import torch.optim as optim

    # Check if there are GPUs. If so, use the first one in the list
    device = torch.device('cuda:0' if torch.cuda.is_available() else 'cpu')
    print(device)

    # Load data and normalize
    transform = transforms.Compose(
        [transforms.ToTensor(), transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5))])

    batch_size = 4
    trainset = torchvision.datasets.CIFAR10(root='./data', train=True,
                                        download=True, transform=transform)
    trainloader = torch.utils.data.DataLoader(trainset, batch_size=batch_size,
                                          shuffle=True, num_workers=2)
    testset = torchvision.datasets.CIFAR10(root='./data', train=False,
                                       download=True, transform=transform)
    testloader = torch.utils.data.DataLoader(testset, batch_size=batch_size,
                                         shuffle=False, num_workers=2)

    # Define the CNN
    class Net(nn.Module):
        def __init__(self):
            super().__init__()
            self.conv1 = nn.Conv2d(3, 6, 5)
            self.pool = nn.MaxPool2d(2, 2)
            self.conv2 = nn.Conv2d(6, 16, 5)
            self.fc1 = nn.Linear(16 * 5 * 5, 120)
            self.fc2 = nn.Linear(120, 84)
            self.fc3 = nn.Linear(84, 10)

        def forward(self, x):
            x = self.pool(F.relu(self.conv1(x)))
            x = self.pool(F.relu(self.conv2(x)))
            x = torch.flatten(x, 1) # flatten all dimensions except batch
            x = F.relu(self.fc1(x))
            x = F.relu(self.fc2(x))
            x = self.fc3(x)
            return x

    net = Net()

    # send the network to the device
    # If you want to use data parallelism across multiple GPUs, uncomment if statement below
    #if torch.cuda.device_count() > 1:
    #    net = nn.DataParallel(net)
    
    net.to(device)

    # Define loss function and optimizer
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.SGD(net.parameters(), lr=0.001, momentum=0.9)

    # Train the network
    for epoch in range(2):  # loop over the dataset multiple times

        running_loss = 0.0
        for i, data in enumerate(trainloader, 0):
            # get the inputs; data is a list of [inputs, labels]
            # inputs, labels = data # setup without device
            inputs, labels = data[0].to(device), data[1].to(device)

            # zero the parameter gradients
            optimizer.zero_grad()

            # forward + backward + optimize
            outputs = net(inputs)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()

            # print statistics
            running_loss += loss.item()
            if i % 2000 == 1999:    # print every 2000 mini-batches
                print(f'[{epoch + 1}, {i + 1:5d}] loss: {running_loss / 2000:.3f}')
                running_loss = 0.0

    print('Finished Training')
    ```

!!! Note
	Currently, this code will run on a single GPU, specifically the GPU denoted ```cuda:0```. To use multiple GPUs via data parallelism, uncomment the two lines above the ```net.to(device)``` command. Furthermore, use of multiple GPUs require requesting multiple GPUs for the batch or interactive job.

!!! Note
	To better observe the multi-GPU peformance of the above example, you can change the size of the CNN. For example, by increasing the size of the second argument in the definition of ```self.conv1``` and the first argument in ```self.conv2```, you can increase the size of the network and use more resources for training.