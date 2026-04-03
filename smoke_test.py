import mjx
from mjx.agents import RandomAgent

print("mjx import: OK")

agent = RandomAgent()
env = mjx.MjxEnv()
obs_dict = env.reset()

step = 0
while not env.done():
    actions = {pid: agent.act(obs) for pid, obs in obs_dict.items()}
    obs_dict = env.step(actions)
    step += 1

returns = env.rewards()
print(f"Game finished in {step} steps")
print(f"Returns: {returns}")
print("mjx smoke test: OK")