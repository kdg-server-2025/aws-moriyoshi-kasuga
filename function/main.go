package main

import (
	"context"
	"encoding/json"
	"log"
	"time"

	"github.com/aws/aws-lambda-go/events"
	runtime "github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-lambda-go/lambdacontext"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/lambda"
)

// Lambdaサービスクライアントを初期化
var client *lambda.Lambda

// AWS SDKを呼び出し、アカウントの情報を取得する
func callLambda() (string, error) {
	input := &lambda.GetAccountSettingsInput{}
	req, resp := client.GetAccountSettingsRequest(input)
	err := req.Send()
	if err != nil {
		return "", err
	}
	output, err := json.Marshal(resp.AccountUsage)
	if err != nil {
		return "", err
	}
	return string(output), nil
}

type ResponseBody struct {
	Message     string `json:"message"`
	CurrentTime string `json:"currentTime"`
	LambdaUsage any    `json:"lambdaUsage"`
	// EnvironmentVars []string `json:"environmentVars"`
	LambdaContext any `json:"lambdaContext"`
}

// HTTPリクエストを処理するハンドラ関数
// 引数と戻り値をAPIGatewayProxyの型に変更
func handleRequest(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	requestJSON, _ := json.MarshalIndent(request, "", "  ")
	log.Printf("REQUEST: %s", requestJSON)

	lc, _ := lambdacontext.FromContext(ctx)
	log.Printf("REQUEST ID: %s", lc.AwsRequestID)

	// AWS SDKを呼び出し
	usageStr, err := callLambda()
	if err != nil {
		log.Printf("Error calling AWS SDK: %v", err)
		// エラーが発生したら500を返す
		return events.APIGatewayProxyResponse{
			StatusCode: 500,
			Body:       "Error getting Lambda account usage.",
		}, err
	}

	var usageJSON any
	json.Unmarshal([]byte(usageStr), &usageJSON)

	// レスポンスボディを作成
	responseBody := ResponseBody{
		Message:     "Successfully processed request!",
		CurrentTime: time.Now().Format(time.RFC3339),
		LambdaUsage: usageJSON,
		// EnvironmentVars: os.Environ(),
		LambdaContext: lc,
	}

	// レスポンスボディをJSON文字列に変換
	responseJSON, err := json.Marshal(responseBody)
	if err != nil {
		return events.APIGatewayProxyResponse{StatusCode: 500}, err
	}

	// 正常なレスポンスを返す
	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Headers: map[string]string{
			"Content-Type": "application/json",
		},
		Body: string(responseJSON),
	}, nil
}

func main() {
	client = lambda.New(session.Must(session.NewSession()))
	runtime.Start(handleRequest)
}
