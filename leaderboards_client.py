import requests

if __name__ == "__main__":
	# The API endpoint
	url = "http://127.0.0.1:8080"

	# A GET request to the API
	response = requests.get(url)

	# Print the response
	response_json = response.json()
	print(response_json)

	# Define new data to create
	new_data = {
	    "name": "jon",
	    "time": 10000,
	    "secret": "quwhrksdbvieurrhrfoqiushffowiihoqusbijqwbv" # top notch security
	}

	# A POST request to the API
	post_response = requests.post(url, json=new_data)

	# Print the response
	post_response_json = post_response.json()
	print(post_response_json)


